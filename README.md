# Discovery's Search Engine Comparison

Comparison of zero results rate for query features across search engines ([T136377](https://phabricator.wikimedia.org/T136377)). The idea is to take a sample of queries exhibiting particular features (and/or combinations of features) and then compare our ZRR with Google's/Bing's/site:wikipedia.org/etc. to see which high-ZRR features on our side have significantly lower ZRR on other search engines. This could highlight certain query categories for us and help us prioritize our work on improving ZRR.

## Setup

### R Packages

```R
install.packages(c("devtools", "magrittr", "tidyverse", "import", "httr", "urltools", "rvest", "binom"))
```

### Hive

The stratified sampling employs [a custom ranking UDF](hive/RankUDF.java) and UDFs from [Wikimedia Analytics' Refinery](https://github.com/wikimedia/analytics-refinery-source).

## Data

1. First, [a shell script](hive/script.sh) runs [this Hive query](hive/query.hql), which returns at most N=100 random queries for each combination of [query features](https://github.com/wikimedia/analytics-refinery-source/blob/master/refinery-core/src/main/java/org/wikimedia/analytics/refinery/core/SearchQuery.java)
2. Those queries are [processed in R](fetch_queries.R) and are manually checked for presence of PII
3. The processed queries are [automatically run through](process_queries.R) major [search engines](search_engines.R)
4. Then we calculate each combination's zero results rate from each engine

## Results

|Combination of features                                                                           | Sample queries| Proportion of all enwiki searches from US| Bing| Cirrus| Google| Google +site:en.wikipedia.org| Yahoo|
|:-------------------------------------------------------------------------------------------------|--------------:|-----------------------------------------:|----:|------:|------:|-----------------------------:|-----:|
|[is simple]                                                                                       |            100|                                91.417227%|  |    12%|    |                           |   |
|[has even double quotes]                                                                          |            100|                                 5.888506%|  |    78%|    |                           |   |
|[ends with ?, has wildcard]                                                                       |            100|                                 0.569473%|  |     9%|    |                           |   |
|[has wildcard]                                                                                    |            100|                                 0.088912%|  |    62%|    |                           |   |
|[has one double quote, has odd double quotes]                                                     |            100|                                 0.059571%|  |    45%|    |                           |   |
|[has logic inversion (-)]                                                                         |            100|                                 0.042736%|  |    20%|    |                           |   |
|[has wildcard, has even double quotes]                                                            |            100|                                 0.009066%|  |    43%|    |                           |   |
|[has logic inversion (-), has even double quotes]                                                 |            100|                                 0.007691%|  |    46%|    |                           |   |
|[ends with ?, has wildcard, has even double quotes]                                               |            100|                                 0.007300%|  |    34%|    |                           |   |
|[has logic inversion (!)]                                                                         |            100|                                 0.004586%|  |    14%|    |                           |   |
|[has odd double quotes]                                                                           |            100|                                 0.003391%|  |    65%|    |                           |   |
|[has wildcard, has one double quote, has odd double quotes]                                       |            100|                                 0.002089%|  |    65%|    |                           |   |
|[ends with ?, has wildcard, has one double quote, has odd double quotes]                          |            100|                                 0.001306%|  |    51%|    |                           |   |
|[has logic inversion (-), has wildcard]                                                           |             67|                                 0.000575%|  |    60%|    |                           |   |
|[ends with ?, has logic inversion (-), has wildcard]                                              |             91|                                 0.000379%|  |    43%|    |                           |   |
|[has quot, has even double quotes]                                                                |             74|                                 0.000302%|  |   100%|    |                           |   |
|[has logic inversion (-), has wildcard, has even double quotes]                                   |             63|                                 0.000261%|  |    13%|    |                           |   |
|[has wildcard, has odd double quotes]                                                             |             54|                                 0.000220%|  |    76%|    |                           |   |
|[has quot]                                                                                        |             48|                                 0.000200%|  |    17%|    |                           |   |
|[has logic inversion (!), has wildcard]                                                           |             43|                                 0.000175%|  |    56%|    |                           |   |
|[has logic inversion (!), has even double quotes]                                                 |             37|                                 0.000151%|  |    57%|    |                           |   |
|[has logic inversion (-), has one double quote, has odd double quotes]                            |             33|                                 0.000135%|  |    67%|    |                           |   |
|[ends with ?]                                                                                     |             19|                                 0.000073%|  |    84%|    |                           |   |
|[has logic inversion (!), has one double quote, has odd double quotes]                            |             18|                                 0.000073%|  |    50%|    |                           |   |
|[ends with ?, has wildcard, has odd double quotes]                                                |             17|                                 0.000069%|  |    94%|    |                           |   |
|[has logic inversion (-), has odd double quotes]                                                  |             14|                                 0.000057%|  |    57%|    |                           |   |
|[ends with ?, has logic inversion (!), has wildcard]                                              |              5|                                 0.000020%|  |    20%|    |                           |   |
|[has logic inversion (!), has wildcard, has one double quote, has odd double quotes]              |              5|                                 0.000020%|  |    80%|    |                           |   |
|[has logic inversion (!), has wildcard, has even double quotes]                                   |              4|                                 0.000016%|  |    75%|    |                           |   |
|[ends with ?, has logic inversion (-), has wildcard, has even double quotes]                      |              3|                                 0.000012%|  |    67%|    |                           |   |
|[ends with ?, has logic inversion (-), has wildcard, has one double quote, has odd double quotes] |              3|                                 0.000012%|  |    33%|    |                           |   |
|[has logic inversion (-), has wildcard, has one double quote, has odd double quotes]              |              3|                                 0.000012%|  |    33%|    |                           |   |
|[has logic inversion (!), has odd double quotes]                                                  |              3|                                 0.000012%|  |    67%|    |                           |   |
|[ends with ?, has wildcard, has quot]                                                             |              1|                                 0.000004%|  |   100%|    |                           |   |
|[has logic inversion (-), has logic inversion (!), has even double quotes]                        |              1|                                 0.000004%|  |   100%|    |                           |   |
|[has logic inversion (-), has wildcard, has odd double quotes]                                    |              1|                                 0.000004%|  |   100%|    |                           |   |
|[has wildcard, has quot]                                                                          |              1|                                 0.000004%|  |   100%|    |                           |   |
