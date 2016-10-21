load("data/queries.RData")
# Loads:
#   - queries                 : an ungrouped data frame created by fetch_queries.R
#       - query               : the query the user searched enwiki for
#       - features            : a comma-separated list of features the query has
#                               each combination of query_features should have N
#                               randomly sampled queries representing the combo
#       - zero_result_enwiki  : a logical indicating that zero results were returned

# Checking...
# queries$features <- sprintf("Feat %02.0f", as.numeric(factor(queries$features)))
# View(arrange(queries, features))

source("search_engines.R")
# Loads:
#   - search_google()
#   - search_google(query, extra = "+site:en.wikipedia.org")
#   - search_bing()
#   - search_yahoo()
#   - search_ddg()
# Inputs: a character vector of queries
# Outputs: a logical vector indicating zero results returned
#   - TRUE when zero results were returned
#   - FALSE when some results were returned
# Notes: all functions are vectorized

# Testing...
# set.seed(42); queries <- sample_n(queries, 10); queries

message("Searching Bing...")
zero_results_bing <- search_bing(queries$query)
save(zero_results_bing, file = "data/zr_bing.RData")
queries$zero_results_bing <- zero_results_bing
message("Searching Google...")
zero_results_google <- search_google(queries$query)
save(zero_results_google, file = "data/zr_google.RData")
queries$zero_results_google <- zero_results_google
message("Searching Google +site:en.wikipedia.org...")
zero_results_enwiki_via_google <- search_google(queries$query, extra = "+site:en.wikipedia.org")
save(zero_results_enwiki_via_google, file = "data/zr_enwiki_via_google.RData")
queries$zero_results_enwiki_via_google <- zero_results_enwiki_via_google
message("Searching Yahoo...")
zero_results_yahoo <- search_yahoo(queries$query)
save(zero_results_yahoo, file = "data/zr_yahoo.RData")
queries$zero_results_yahoo <- zero_results_yahoo
message("Searching DuckDuckGo...")
zero_results_ddg <- search_ddg(queries$query)
save(zero_results_ddg, file = "data/zr_ddg.RData")
queries$zero_results_ddg <- zero_results_ddg

save(queries, file = "data/processed.RData")
