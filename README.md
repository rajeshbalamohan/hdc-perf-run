For Hive-2/LLAP
  1. Clone this repository
  2. Spin up HDC cluster (Settings given here are specific to i2 4x large instance types; 16 CPU x 122 GB)
  3. Run "sh tune.sh" to tune to the cluster
  4. Restart all needed services in ambari
  5. Run TPC-DS queries by "cd tpc-ds; sh beeline_run.sh"

For Hive-1, 
  1. make use of settings-hive-1.csv. Rename to settings.csv when running with hive-1. 
  2. Run "sh tune.sh" to tune the cluster. Just in case "hive.metastore.pre.event.listeners" shows RED in ambari, explicitly set it to WHITESPACE and save it.
  3. Restart all needed services in ambari
  2. "sh beeline_hive_1_run.sh" for hive-1 benchmarks. This internally uses hive-1's beeline client and connection parameters.

In case you would like to tune OS settings, you can run "sysctl_tune.sh" on all nodes which sets network tuning parameters.

Logs are written to local folder. 54 queries are executed in total. Grep for "grep 'DAG finished' <log_file>" to get DAG runtimes.

Following queries are executed.

query12.sql
query15.sql
query17.sql
query18.sql
query19.sql
query20.sql
query21.sql
query22.sql
query25.sql
query26.sql
query27.sql
query3.sql
query31.sql
query32.sql
query34.sql
query39a.sql
query39b.sql
query40.sql
query42.sql
query43.sql
query45.sql
query46.sql
query50.sql
query52.sql
query54.sql
query55.sql
query56.sql
query58.sql
query60.sql
query66.sql
query67.sql
query68.sql
query7.sql
query70.sql
query71.sql
query73.sql
query75.sql
query76.sql
query79.sql
query80.sql
query82.sql
query84.sql
query85.sql
query87.sql
query88.sql
query89.sql
query90.sql
query91.sql
query92.sql
query93.sql
query94.sql
query95.sql
query96.sql
query97.sql
query98.sql
