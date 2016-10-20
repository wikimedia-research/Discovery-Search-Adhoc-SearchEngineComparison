# Compile Rank class
HIVE_HOME=/usr/lib/hive
javac -classpath $HIVE_HOME/lib/hive-serde.jar:$HIVE_HOME/lib/hive-exec.jar:/usr/lib/hive-hcatalog/share/hcatalog/hive-hcatalog-core.jar -d ~/tmp/ RankUDF.java

# Create Rank jar
jar -cf RankUDF.jar org/wikimedia/discovery/refinery/hive/RankUDF.class

hive -f extract_queries.hql > queries.tsv

hive -f count_features.hql > features.tsv
