library(magrittr) # for piping
library(parallel) # to run multiple queries simulatenously
options(mc.cores = parallel::detectCores())
library(rvest) # to scrape Google and Yahoo's SERPs
library(urltools) # to encode queries
library(httr) # to use Bing API
library(progress)

search_google <- function(q, extra = NULL) {
  # Google does not have a search API so we gotta do some web-scraping:
  pb <- progress_bar$new(total = length(q))
  return({
    q %>%
      url_encode %>%
      paste0("https://www.google.com/search?q=", ., extra) %>%
      lapply(function(a_url) {
        pb$tick(); Sys.sleep(sample.int(5, 1)) # Makes randomly-spaced requests (between 0 and 5s)
        return({
          tryCatch({
            fetched_html <- read_html(a_url)
            (length(html_nodes(fetched_html, xpath = "//div[@id='res'][contains(., 'No results found for')]")) > 0) || (length(html_nodes(fetched_html, xpath = "//p[contains(., 'Your search') and contains(., 'did not match any documents.')]")) > 0)
          }, error = function(e) {
            message(paste("Problem fetching HTML for the URL:", a_url))
            message(e)
            return(NA)
          })
        })
      }) %>%
      unlist
  })
}

search_yahoo <- function(q) {
  # Yahoo used to have a search API (https://developer.yahoo.com/boss/search/)
  # but it got shut down on March 31, 2016, so we gotta do some web-scraping:
  pb <- progress_bar$new(total = length(q))
  return({
    q %>%
      url_encode %>%
      paste0("https://search.yahoo.com/search?p=", ., "&ei=UTF-8&fp=1&nojs=1") %>%
      lapply(function(a_url) {
        pb$tick(); Sys.sleep(sample.int(5, 1)) # Makes randomly-spaced requests (between 0 and 5s)
        return({
          tryCatch({
            fetched_html <- read_html(a_url)
            length(html_nodes(fetched_html, xpath = "//p[contains(., 'We did not find results for: ')]")) > 0
          }, error = function(e) {
            message(paste("Problem fetching HTML for the URL:", a_url))
            message(e)
            return(NA)
          })
        })
      }) %>%
      unlist
  })
}

source("api_keys.R")
search_bing_api <- function(q) {
  # Microsoft Bing has a search API.
  return({
    q %>%
      mclapply(function(query) {
        pb$tick()
        response <- GET(url = 'https://api.cognitive.microsoft.com/bing/v5.0/search',
                        query = list(q = query, count = 1),
                        add_headers("Ocp-Apim-Subscription-Key" = api_keys$bing[1]))
        results <- content(response, encoding = "json")
        return(!("webPages" %in% names(results)))
      }, mc.cores = parallel::detectCores()) %>%
      unlist
  })
}

search_bing <- function(q) {
  # Microsoft Bing has a search API, but there's a cap of 1K/mo and maybe ToS prohibit this kind of use?
  # Resort to scraping... *sigh*
  pb <- progress_bar$new(total = length(q))
  return({
    q %>%
      url_encode %>%
      paste0("http://www.bing.com/search?q=", .) %>%
      lapply(function(a_url) {
        pb$tick(); Sys.sleep(sample.int(5, 1)) # Makes randomly-spaced requests (between 0 and 5s)
        return({
          tryCatch({
            fetched_html <- read_html(a_url)
            length(html_nodes(fetched_html, xpath = "//ol[@aria-label='Search Results']//h1[contains(., 'No results found for ')]")) > 0
          }, error = function(e) {
            message(paste("Problem fetching HTML for the URL:", a_url))
            message(e)
            return(NA)
          })
        })
      }) %>%
      unlist
  })
}

search_ddg <- function(q) {
  # DuckDuckGo does have an API but not for getting web search results
  pb <- progress_bar$new(total = length(q))
  return({
    q %>%
      url_encode %>%
      paste0("https://duckduckgo.com/html/?q=", .) %>%
      lapply(function(a_url) {
        pb$tick(); Sys.sleep(sample.int(5, 1)) # Makes randomly-spaced requests (between 0 and 5s)
        return({
          tryCatch({
            fetched_html <- read_html(a_url)
            length(html_nodes(fetched_html, "div.no-results")) > 0
          }, error = function(e) {
            message(paste("Problem fetching HTML for the URL:", a_url))
            message(e)
            return(NA)
          })
        })
      }) %>%
      unlist
  })
}
