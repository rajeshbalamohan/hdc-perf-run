#!/bin/bash
hdpVersion=$(hdp-select versions)
bline=/usr/hdp/${hdpVersion}/hive2/bin/beeline
jdbcUrl="jdbc:hive2://`hostname`:2181/tpcds_bin_partitioned_newschema_orc_200;serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=hiveserver2-hive2"

echo "HDP Version : " ${hdpVersion}
echo "JDBC URL : " ${jdbcUrl}
echo "Beeline : " ${bline}

for i in {1..3}
do
  echo "Running " ${i}
  ${bline} -u "${jdbcUrl}" -f beeline_llapexec_tpcds_queries_without_q51_q72.sql > beeline_llapexec_tpcds_queries_without_q51_q72.sql.200.${i}.new_schema.log 2>&1 
  echo "Sleep for 60 seconds. tez.am.dag.submit.timeout.secs set to 30 seconds"
  sleep 60
done
