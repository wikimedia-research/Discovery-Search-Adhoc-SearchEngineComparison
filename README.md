Discovery's Search Engine Comparison
====================================

Comparison of zero results rate for query features across search engines ([T136377](https://phabricator.wikimedia.org/T136377)). The idea is to take a sample of queries exhibiting particular features (and/or combinations of features) and then compare our ZRR with Google's/Bing's/site:wikipedia.org/etc. to see which high-ZRR features on our side have significantly lower ZRR on other search engines. This could highlight certain query categories for us and help us prioritize our work on improving ZRR.

Setup
-----

### R Packages

``` r
install.packages(c("devtools", "magrittr", "tidyverse", "import", "httr", "urltools", "rvest", "binom"))
```

### Hive

The stratified sampling employs [a custom ranking UDF](hive/RankUDF.java) and UDFs from [Wikimedia Analytics' Refinery](https://github.com/wikimedia/analytics-refinery-source).

Data
----

1.  First, [a shell script](hive/script.sh) runs [this Hive query](hive/extract_queries.hql), which returns at most N=100 random queries for each combination of [query features](https://github.com/wikimedia/analytics-refinery-source/blob/master/refinery-core/src/main/java/org/wikimedia/analytics/refinery/core/SearchQuery.java)
2.  Those queries are [processed in R](fetch_queries.R) and are manually checked for presence of PII
3.  The processed queries are [automatically run through](process_queries.R) major [search engines](search_engines.R)
4.  We also calculate the % of total queries that each combination of features represents by [counting queries by features](hive/count_features.hql)
5.  Then we calculate each combination's zero results rate from each engine

Results
-------

The bots encountered problems performing some searches, so the table below is incomplete, but should provide a good starting point for discussion. Not all queries were successfully searched for, so we include the fraction of zero result SERPs out of successfully searched queries on a per-engine basis. The "Proportion" column represents the % of full-text searches performed on EnWiki by U.S.-based website visitors on desktops in September and October of 2016.

<table>
<colgroup>
<col width="54%" />
<col width="6%" />
<col width="7%" />
<col width="7%" />
<col width="7%" />
<col width="7%" />
<col width="7%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Features</th>
<th align="right">Proportion</th>
<th align="right">Cirrus ZRR</th>
<th align="right">Google ZRR</th>
<th align="right">Yahoo ZRR</th>
<th align="right">Bing ZRR</th>
<th align="right">DDG ZRR</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">[is simple]</td>
<td align="right">91.417227%</td>
<td align="right">12% (12/100)</td>
<td align="right">1% (1/100)</td>
<td align="right">3% (3/100)</td>
<td align="right">2% (2/100)</td>
<td align="right">2% (2/100)</td>
</tr>
<tr class="even">
<td align="left">[has even double quotes]</td>
<td align="right">5.888506%</td>
<td align="right">78% (78/100)</td>
<td align="right">20% (20/100)</td>
<td align="right">27% (27/100)</td>
<td align="right">25% (25/100)</td>
<td align="right">41% (30/74)</td>
</tr>
<tr class="odd">
<td align="left">[ends with ?, has wildcard]</td>
<td align="right">0.569473%</td>
<td align="right">9% (9/100)</td>
<td align="right"></td>
<td align="right">0% (0/100)</td>
<td align="right">0% (0/100)</td>
<td align="right">0% (0/99)</td>
</tr>
<tr class="even">
<td align="left">[has wildcard]</td>
<td align="right">0.088912%</td>
<td align="right">62% (62/100)</td>
<td align="right"></td>
<td align="right">41% (41/100)</td>
<td align="right">42% (40/95)</td>
<td align="right">18% (16/90)</td>
</tr>
<tr class="odd">
<td align="left">[has one double quote, has odd double quotes]</td>
<td align="right">0.059571%</td>
<td align="right">45% (45/100)</td>
<td align="right">6% (6/100)</td>
<td align="right">8% (8/99)</td>
<td align="right">7% (7/100)</td>
<td align="right">21% (21/98)</td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (-)]</td>
<td align="right">0.042736%</td>
<td align="right">20% (20/100)</td>
<td align="right"></td>
<td align="right">6% (6/100)</td>
<td align="right">6% (6/100)</td>
<td align="right">11% (11/97)</td>
</tr>
<tr class="odd">
<td align="left">[has wildcard, has even double quotes]</td>
<td align="right">0.009066%</td>
<td align="right">43% (43/100)</td>
<td align="right"></td>
<td align="right">43% (43/100)</td>
<td align="right">41% (40/98)</td>
<td align="right">36% (29/80)</td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (-), has even double quotes]</td>
<td align="right">0.007691%</td>
<td align="right">46% (46/100)</td>
<td align="right"></td>
<td align="right">26% (26/100)</td>
<td align="right">25% (25/100)</td>
<td align="right">43% (40/92)</td>
</tr>
<tr class="odd">
<td align="left">[ends with ?, has wildcard, has even double quotes]</td>
<td align="right">0.007300%</td>
<td align="right">34% (34/100)</td>
<td align="right">4% (1/25)</td>
<td align="right">7% (7/100)</td>
<td align="right">6% (6/100)</td>
<td align="right">13% (13/100)</td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (!)]</td>
<td align="right">0.004586%</td>
<td align="right">14% (14/100)</td>
<td align="right"></td>
<td align="right">7% (7/100)</td>
<td align="right">6% (6/100)</td>
<td align="right">5% (5/94)</td>
</tr>
<tr class="odd">
<td align="left">[has odd double quotes]</td>
<td align="right">0.003391%</td>
<td align="right">65% (65/100)</td>
<td align="right">28% (28/99)</td>
<td align="right">44% (44/99)</td>
<td align="right">44% (44/99)</td>
<td align="right">59% (49/83)</td>
</tr>
<tr class="even">
<td align="left">[has wildcard, has one double quote, has odd double quotes]</td>
<td align="right">0.002089%</td>
<td align="right">65% (65/100)</td>
<td align="right">35% (35/100)</td>
<td align="right">51% (49/97)</td>
<td align="right">45% (45/100)</td>
<td align="right">64% (54/84)</td>
</tr>
<tr class="odd">
<td align="left">[ends with ?, has wildcard, has one double quote, has odd double quotes]</td>
<td align="right">0.001306%</td>
<td align="right">51% (51/100)</td>
<td align="right"></td>
<td align="right">10% (10/99)</td>
<td align="right">10% (10/100)</td>
<td align="right">36% (35/96)</td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (-), has wildcard]</td>
<td align="right">0.000575%</td>
<td align="right">60% (40/67)</td>
<td align="right"></td>
<td align="right">33% (22/67)</td>
<td align="right">32% (21/65)</td>
<td align="right">16% (8/51)</td>
</tr>
<tr class="odd">
<td align="left">[ends with ?, has logic inversion (-), has wildcard]</td>
<td align="right">0.000379%</td>
<td align="right">43% (39/91)</td>
<td align="right">8% (7/91)</td>
<td align="right">20% (17/87)</td>
<td align="right">19% (17/91)</td>
<td align="right">3% (3/89)</td>
</tr>
<tr class="even">
<td align="left">[has quot, has even double quotes]</td>
<td align="right">0.000302%</td>
<td align="right">100% (74/74)</td>
<td align="right">0% (0/1)</td>
<td align="right">5% (4/74)</td>
<td align="right">5% (4/74)</td>
<td align="right">23% (6/26)</td>
</tr>
<tr class="odd">
<td align="left">[has logic inversion (-), has wildcard, has even double quotes]</td>
<td align="right">0.000261%</td>
<td align="right">13% (8/63)</td>
<td align="right"></td>
<td align="right">5% (3/63)</td>
<td align="right">5% (3/61)</td>
<td align="right">16% (10/63)</td>
</tr>
<tr class="even">
<td align="left">[has wildcard, has odd double quotes]</td>
<td align="right">0.000220%</td>
<td align="right">76% (41/54)</td>
<td align="right">56% (30/54)</td>
<td align="right">57% (31/54)</td>
<td align="right">56% (30/54)</td>
<td align="right">79% (38/48)</td>
</tr>
<tr class="odd">
<td align="left">[has quot]</td>
<td align="right">0.000200%</td>
<td align="right">17% (8/48)</td>
<td align="right"></td>
<td align="right">0% (0/48)</td>
<td align="right">2% (1/48)</td>
<td align="right">0% (0/48)</td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (!), has wildcard]</td>
<td align="right">0.000175%</td>
<td align="right">56% (24/43)</td>
<td align="right">42% (18/43)</td>
<td align="right">53% (23/43)</td>
<td align="right">58% (25/43)</td>
<td align="right">18% (7/39)</td>
</tr>
<tr class="odd">
<td align="left">[has logic inversion (!), has even double quotes]</td>
<td align="right">0.000151%</td>
<td align="right">57% (21/37)</td>
<td align="right"></td>
<td align="right">27% (10/37)</td>
<td align="right">24% (9/37)</td>
<td align="right">24% (8/34)</td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (-), has one double quote, has odd double quotes]</td>
<td align="right">0.000135%</td>
<td align="right">67% (22/33)</td>
<td align="right"></td>
<td align="right">30% (10/33)</td>
<td align="right">33% (11/33)</td>
<td align="right">58% (18/31)</td>
</tr>
<tr class="odd">
<td align="left">[ends with ?]</td>
<td align="right">0.000073%</td>
<td align="right">84% (16/19)</td>
<td align="right"></td>
<td align="right">100% (19/19)</td>
<td align="right">100% (19/19)</td>
<td align="right">100% (12/12)</td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (!), has one double quote, has odd double quotes]</td>
<td align="right">0.000073%</td>
<td align="right">50% (9/18)</td>
<td align="right">12% (2/17)</td>
<td align="right">28% (5/18)</td>
<td align="right">24% (4/17)</td>
<td align="right">53% (9/17)</td>
</tr>
<tr class="odd">
<td align="left">[ends with ?, has wildcard, has odd double quotes]</td>
<td align="right">0.000069%</td>
<td align="right">94% (16/17)</td>
<td align="right">24% (4/17)</td>
<td align="right">24% (4/17)</td>
<td align="right">24% (4/17)</td>
<td align="right">82% (14/17)</td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (-), has odd double quotes]</td>
<td align="right">0.000057%</td>
<td align="right">57% (8/14)</td>
<td align="right">21% (3/14)</td>
<td align="right">36% (5/14)</td>
<td align="right">36% (5/14)</td>
<td align="right">42% (5/12)</td>
</tr>
<tr class="odd">
<td align="left">[ends with ?, has logic inversion (!), has wildcard]</td>
<td align="right">0.000020%</td>
<td align="right">20% (1/5)</td>
<td align="right">20% (1/5)</td>
<td align="right">20% (1/5)</td>
<td align="right">20% (1/5)</td>
<td align="right">0% (0/5)</td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (!), has wildcard, has one double quote, has odd double quotes]</td>
<td align="right">0.000020%</td>
<td align="right">80% (4/5)</td>
<td align="right">20% (1/5)</td>
<td align="right">60% (3/5)</td>
<td align="right">60% (3/5)</td>
<td align="right">0% (0/3)</td>
</tr>
<tr class="odd">
<td align="left">[has logic inversion (!), has wildcard, has even double quotes]</td>
<td align="right">0.000016%</td>
<td align="right">75% (3/4)</td>
<td align="right">75% (3/4)</td>
<td align="right">75% (3/4)</td>
<td align="right">75% (3/4)</td>
<td align="right">50% (2/4)</td>
</tr>
<tr class="even">
<td align="left">[ends with ?, has logic inversion (-), has wildcard, has even double quotes]</td>
<td align="right">0.000012%</td>
<td align="right">67% (2/3)</td>
<td align="right"></td>
<td align="right">33% (1/3)</td>
<td align="right">33% (1/3)</td>
<td align="right">67% (2/3)</td>
</tr>
<tr class="odd">
<td align="left">[ends with ?, has logic inversion (-), has wildcard, has one double quote, has odd double quotes]</td>
<td align="right">0.000012%</td>
<td align="right">33% (1/3)</td>
<td align="right">33% (1/3)</td>
<td align="right">0% (0/3)</td>
<td align="right">0% (0/3)</td>
<td align="right">67% (2/3)</td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (-), has wildcard, has one double quote, has odd double quotes]</td>
<td align="right">0.000012%</td>
<td align="right">33% (1/3)</td>
<td align="right"></td>
<td align="right">33% (1/3)</td>
<td align="right">33% (1/3)</td>
<td align="right">67% (2/3)</td>
</tr>
<tr class="odd">
<td align="left">[has logic inversion (!), has odd double quotes]</td>
<td align="right">0.000012%</td>
<td align="right">67% (2/3)</td>
<td align="right">67% (2/3)</td>
<td align="right">67% (2/3)</td>
<td align="right">33% (1/3)</td>
<td align="right">67% (2/3)</td>
</tr>
<tr class="even">
<td align="left">[ends with ?, has wildcard, has quot]</td>
<td align="right">0.000004%</td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
<td align="right">0% (0/1)</td>
</tr>
<tr class="odd">
<td align="left">[has logic inversion (-), has logic inversion (!), has even double quotes]</td>
<td align="right">0.000004%</td>
<td align="right">100% (1/1)</td>
<td align="right"></td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
<td align="right"></td>
</tr>
<tr class="even">
<td align="left">[has logic inversion (-), has wildcard, has odd double quotes]</td>
<td align="right">0.000004%</td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
</tr>
<tr class="odd">
<td align="left">[has wildcard, has quot]</td>
<td align="right">0.000004%</td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
<td align="right">100% (1/1)</td>
<td align="right"></td>
</tr>
</tbody>
</table>
