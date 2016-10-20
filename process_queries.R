load("data/queries.RData")
# Loads:
#   - queries                 : an ungrouped data frame created by fetch_queries.R
#       - query               : the query the user searched enwiki for
#       - features            : a comma-separated list of features the query has
#                               each combination of query_features should have N
#                               randomly sampled queries representing the combo
#       - zero_result_enwiki  : a logical indicating that zero results were returned

source("search_engines.R")
# Loads:
#   - search_google()
#   - search_google(query, extra = "+site:en.wikipedia.org")
#   - search_bing()
#   - search_yahoo()
# Inputs: a character vector of queries
# Outputs: a logical vector indicating zero results returned
#   - TRUE when zero results were returned
#   - FALSE when some results were returned
# Notes: all functions are vectorized

queries$zero_results_google <- search_google(queries$query)
queries$zero_results_enwiki_via_google <- search_google(queries$query, extra = "+site:en.wikipedia.org")
queries$zero_results_yahoo <- search_yahoo(queries$query)
queries$zero_results_bing <- search_bing(queries$query)

save(queries, file = "data/processed.RData")
