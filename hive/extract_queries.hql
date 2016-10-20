ADD JAR hdfs:///wmf/refinery/current/artifacts/refinery-hive.jar;
CREATE TEMPORARY FUNCTION ua_parser AS 'org.wikimedia.analytics.refinery.hive.UAParserUDF';
CREATE TEMPORARY FUNCTION is_spider AS 'org.wikimedia.analytics.refinery.hive.IsSpiderUDF';
CREATE TEMPORARY FUNCTION array_sum AS 'org.wikimedia.analytics.refinery.hive.ArraySumUDF';
CREATE TEMPORARY FUNCTION geocode_country as 'org.wikimedia.analytics.refinery.hive.GeocodedCountryUDF';
CREATE TEMPORARY FUNCTION deconstruct AS 'org.wikimedia.analytics.refinery.hive.DeconstructSearchQueryUDF';
ADD JAR file:///home/bearloga/tmp/RankUDF.jar;
CREATE TEMPORARY FUNCTION rank AS 'org.wikimedia.discovery.refinery.hive.RankUDF';

SELECT query, features, zero_result AS zero_result_enwiki
FROM (
  SELECT *, rank(features) AS ranking
  FROM (
    SELECT *
    FROM (
      SELECT
        query, deconstruct(query) AS features, zero_result
      FROM (
        SELECT DISTINCT
          REGEXP_REPLACE(TRIM(LOWER(requests.query[SIZE(requests.query)-1])), '\\t', ' ') AS query,
          array_sum(requests.hitstotal, -1) = 0 AS zero_result
        FROM wmf_raw.CirrusSearchRequestSet
        WHERE
          year = 2016 AND month > 8
          AND wikiid = 'enwiki' AND source = 'web' AND SIZE(backendusertests) = 0
          AND NOT (ua_parser(useragent)['device_family'] = 'Spider' OR is_spider(useragent) OR ip = '127.0.0.1')
          AND requests[size(requests)-1].querytype = 'full_text'
          AND geocode_country(ip) = 'US'
      ) unique_queries
    ) deconstructed_queries
    WHERE
      INSTR(features, 'has non-ASCII') = 0 -- Currently interested in English queries
      AND INSTR(features, 'has @') = 0 -- Eliminates email addresses
      AND NOT (query RLIKE '^[0-9]{3}-?[0-9]{2}-?[0-9]{4}$')  -- Eliminates SSNs
      -- Then we'll get rid of a bunch of queries that have features we're not interested in comparing across engines
      AND INSTR(features, 'is null') = 0
      AND INSTR(features, 'is insource') = 0
      AND INSTR(features, 'is prefix') = 0
      AND INSTR(features, 'is incategory') = 0
      AND INSTR(features, 'is intitle') = 0
      AND INSTR(features, 'is empty') = 0
      AND INSTR(features, 'is just') = 0
      AND INSTR(features, 'is searchTerms') = 0
      AND INSTR(features, 'forces search results') = 0
      AND INSTR(features, 'is fuzzy search') = 0
      AND INSTR(features, 'is only punctuation and spaces') = 0
    DISTRIBUTE BY features
    SORT BY features, RAND()
  ) distributed_queries
) ranked_queries
WHERE ranking < 100;
