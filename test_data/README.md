# Generate

## Generate the test data

```
$ /usr/bin/python3 ./test_data/anxiety-levels.py > anxiety-levels.om
Simulation starts: 2022-12-31 21:15:54
Simulation ends: 2023-01-07 21:15:54.024699
Scrape interval: 0:00:15
Total scrapes: 40320
```

The generated data should look like the following, which is in OpenMetrics format.

```
# HELP anxiety_level A gauge that should illustrate a churn problem
# TYPE anxiety_level gauge
anxiety_level{shard="46",client="81"} 634 1672474569.0
anxiety_level{shard="69",client="e2f4af"} 634 1672474569.0
...
# EOF
```

# Import into Prometheus

```
## Copy the data into the Prometheus running container

$ docker cp anxiety-levels.om prometheus-grafana-nginx-lua-prometheus-1:/prometheus/

## Shell into the container

$ docker exec -it prometheus-grafana-nginx-lua-prometheus-1 /bin/sh

## Make a temporary directory; it will consume about 172 MB.
# /prometheus is mounted # as a volume-mount in our docker-compose.yml

/prometheus $ mkdir NEW
/prometheus $ promtool tsdb create-blocks-from openmetrics anxiety-levels.om ./NEW/
BLOCK ULID MIN TIME MAX TIME DURATION NUM SAMPLES NUM CHUNKS NUM SERIES SIZE 01GP5Z71W2RPRENGTPGCRZQWQ0 1672474569000 1672480794001 1h43m45.001s 23457 19849 19849 1895194
... one line for every 2 hours by default

## Assuming it completed without complaint
/prometheus $ mv NEW/* .
/prometheus $ rmdir NEW
/prometheus $ rm anxiety-levels.om
```

# Delete from Prometheus

Reference: [TSDB Admin APIs](https://prometheus.io/docs/prometheus/latest/querying/api/#tsdb-admin-apis)

Reconfigure Prometheus with `--web.enable-admin-api` (see docker-compose.yml)

Mark the data as deleted, which adds a tombstone marker. You should get a 204 'No Content' on success. The data will no-longer be returned by a query. 

```bash
curl -is -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]=anxiety_level'
```

Now optionally ask Prometheus to immediately delete data currently marked for deletion, rather than waiting for compaction (which may never come for old blocks?). It will take a bit longer to run, but should still be reasonably quick (~1s) for this data. And again you should get a 204 'No Content' on success.

```bash
curl -is -XPOST http://localhost:9090/api/v1/admin/tsdb/clean_tombstones
```

Disable `--web.enable-admin-api` when done.
