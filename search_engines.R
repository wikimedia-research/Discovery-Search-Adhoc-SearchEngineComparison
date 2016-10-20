library(magrittr) # for piping
library(parallel) # to run multiple queries simulatenously
options(mc.cores = parallel::detectCores())
library(rvest) # to scrape Google and Yahoo's SERPs
library(urltools) # to encode queries
library(httr) # to use Bing API

queries <- c("google search api", '"ubuntu install boom r package error C++11 make cannot find"', '"ubuntu install boom r package error C++11 make cannot find" +dddddd')

search_google <- function(queries, extra = NULL) {
  # Google does not have a search API so we gotta do some web-scraping:
  return({
    queries %>%
      url_encode %>%
      paste0("https://www.google.com/search?q=", ., extra) %>%
      mclapply(function(a_url) {
        fetched_html <- read_html(a_url)
        return(
          (length(html_nodes(fetched_html, xpath = "//div[@id='res'][contains(., 'No results found for')]")) > 0) ||
            (length(html_nodes(fetched_html, xpath = "//p[contains(., 'Your search') and contains(., 'did not match any documents.')]")) > 0)
        )
      }) %>%
      unlist
  })
}

search_yahoo <- function(queries) {
  # Yahoo used to have a search API (https://developer.yahoo.com/boss/search/)
  # but it got shut down on March 31, 2016, so we gotta do some web-scraping:
  return({
    results <- queries %>%
      url_encode %>%
      paste0("https://search.yahoo.com/search;_ylc=X3oDMTFiN25laTRvBF9TAzIwMjM1MzgwNzUEaXRjAzEEc2VjA3NyY2hfcWEEc2xrA3NyY2h3ZWI-?p=", .) %>%
      mclapply(function(a_url) {
        fetched_html <- read_html(a_url)
        return(length(html_nodes(fetched_html, xpath = "//p[contains(., 'We did not find results for: ')]")) > 0)
      }) %>%
      unlist
  })
}

source("api_keys.R")
search_bing <- function(queries) {
  # Microsoft Bing has a search API.
  return({
    queries %>%
      mclapply(function(query) {
        response <- GET(url = 'https://api.cognitive.microsoft.com/bing/v5.0/search',
                        query = list(q = query, count = 1),
                        add_headers("Ocp-Apim-Subscription-Key" = api_keys$bing[1]))
        results <- content(response, encoding = "json")
        return(!("webPages" %in% names(results)))
      }) %>%
      unlist
  })
}
