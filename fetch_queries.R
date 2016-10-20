if (!dir.exists("data")) { dir.create("data") }

system("scp stat2:/home/bearloga/tmp/queries.tsv data/")

queries <- read.delim("data/queries.tsv", sep = "\t", as.is = TRUE, quote = "")

queries <- queries[queries$features != "" & grepl("^\\[.*\\]$", queries$features), ]
queries$zero_result_enwiki <- queries$zero_result_enwiki == "true"

save(queries, file = "data/queries.RData")

system("scp stat2:/home/bearloga/tmp/features.tsv data/")

features <- read.csv("data/features.csv", stringsAsFactors = FALSE)
# features <- features[!is.na(features$queries), ]

features$proportion_total <- features$queries/sum(features$queries)
features$proportion_interested <- c(NA, features$queries[-1]/sum(features$queries[-1]))

save(features, file = "data/features.RData")
