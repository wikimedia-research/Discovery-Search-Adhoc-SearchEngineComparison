package org.wikimedia.discovery.refinery.hive;
import org.apache.hadoop.hive.ql.exec.UDF;

/**
 * A Hive UDF to rank rows in a group, allowing to select top N
 * rows per group (including ones sorted by random value).
 * Hive Usage:
 *   ADD JAR /path/to/RankUDF.jar;
 *   CREATE TEMPORARY FUNCTION rank AS 'org.wikimedia.discovery.refinery.hive.RankUDF';
 *   SELECT id, field1, ..., fieldP
 *   FROM (
 *     SELECT
 *       *, rank(grouping_id) AS ranking
 *     FROM (
 *       SELECT
 *         grouping_id, field1, ..., fieldP
 *       FROM some_table
 *       DISTRIBUTE BY grouping_id
 *       SORT BY grouping_id, RAND()
 *     ) X
 *   ) Y
 *   WHERE ranking < N;
 * <p>
 * From: https://ragrawal.wordpress.com/2011/11/18/extract-top-n-records-in-each-group-in-hadoophive/
 * </p>
 * <p>
 * Alternative, pure-HiveQL approach that yields proportional stratified samples:
 * https://azure.microsoft.com/en-us/documentation/articles/machine-learning-data-science-sample-data-hive/#stratified
 * </p>
 */

public final class RankUDF extends UDF{
    private int counter;
    private String last_key;
    public int evaluate(final String key){
      if ( !key.equalsIgnoreCase(this.last_key) ) {
         this.counter = 0;
         this.last_key = key;
      }
      return this.counter++;
    }
}
