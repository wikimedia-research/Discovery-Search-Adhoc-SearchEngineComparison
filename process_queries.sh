# Locally:
cd /Users/mpopov/Documents/Projects/Search/Adhoc/Search\ Engine\ Comparison
scp process_queries.R bearloga@big-bae.eqiad.wmflabs:/home/bearloga/search_engine_comparison/
scp data/queries.RData bearloga@big-bae.eqiad.wmflabs:/home/bearloga/search_engine_comparison/data/
scp search_engines.R bearloga@big-bae.eqiad.wmflabs:/home/bearloga/search_engine_comparison/
scp api_keys.R bearloga@big-bae.eqiad.wmflabs:/home/bearloga/search_engine_comparison/

# Remotely:
cd ~/search_engine_comparison
Rscript process_queries.R
