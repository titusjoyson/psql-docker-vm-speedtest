# psql-docker-vm-speedtest
A speed test between PostgreSQL in docker and on VM

### Setup the requirements

1. Install [Sysbench](https://github.com/akopytov/sysbench)
2. Install [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
3. Setup [PostgreSQL](https://www.postgresql.org/download/linux/ubuntu/) after setup follow the below
```sh
$ su - postgres
$ psql
> CREATE USER 'sbtest' WITH PASSWORD 'password';
> CREATE DATABASE sbtest
> GRANT ALL PRIVILEGES ON DATABASE sbtest to sbtest;
```
4. Load the data by runnin the following
```sh
$ sysbench \
--db-driver=pgsql \
--oltp-table-size=100000 \
--oltp-tables-count=24 \
--threads=1 \
--pgsql-host=127.0.0.1 \
--pgsql-port=5432 \
--pgsql-user=sbtest \
--pgsql-password=password \
--pgsql-db=sbtest \
/usr/share/sysbench/tests/include/oltp_legacy/parallel_prepare.lua \
run
```
The above command generates 100,000 rows per table for 24 tables (sbtest1 to sbtest24) inside database 'sbtest'. The schema name is "public" which is the default. The data is prepared by a script called parallel_prepare.lua which available under /usr/share/sysbench/tests/include/oltp_legacy.
5. Do Read/Write Load
```sh
$ sysbench \
--db-driver=pgsql \
--report-interval=2 \
--oltp-table-size=100000 \
--oltp-tables-count=24 \
--threads=64 \
--time=60 \
--pgsql-host=127.0.0.1 \
--pgsql-port=5432 \
--pgsql-user=sbtest \
--pgsql-password=password \
--pgsql-db=sbtest \
/usr/share/sysbench/tests/include/oltp_legacy/oltp.lua \
run
```
The above command will generate the OLTP workload from the LUA script called /usr/share/sysbench/tests/include/oltp_legacy/oltp.lua, against 100,000 rows of 24 tables with 64 worker threads for 60 seconds on host 27.0.0.1 (master). Every 2 seconds, sysbench will report the intermediate statistics (--report-interval=2).

When the test was ongoing, we can monitor the PostgreSQL activity using pg_activity or pg_top, to confirm the intermediate statistic reported by sysbench
6. In another terminal, do
```sh
$ su - postgres
$ pg_activity
```
As well as the replication stream by looking at the pg_stat_replication table on the master server:
```sh
$ su - postgres
$ watch -n1 'psql -xc "select * from pg_stat_replication"'
```
The above "watch" command runs the psql command every 1 second. You should see "*_location" columns are updated accordingly when replication happens.

At the end of the test, you should see the summary

7. Setup [PostgreSQL Docker](https://hub.docker.com/_/postgres)
```sh
$ docker run --name test-postgres -d -p 5432:5432 -e POSTGRES_PASSWORD=password -e POSTGRES_USER=sbtest -d postgres:11

$ psql -h localhost -U sbtest

> CREATE DATABASE sbtest
> GRANT ALL PRIVILEGES ON DATABASE sbtest to sbtest;
```

Container steps (4 - 5)

### Ref
[https://severalnines.com/database-blog/how-benchmark-postgresql-performance-using-sysbench](https://severalnines.com/database-blog/how-benchmark-postgresql-performance-using-sysbench)