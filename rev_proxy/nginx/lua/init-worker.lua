cjson = require 'cjson'

prometheus = require("prometheus").init("prometheus_metrics")

-- Remember that this may produce a number of metrics equal to the
-- product of the cardinality of label, including the bucket ranges.
-- If that is of concern, perhaps don't include the panel, or reduce
-- the number of buckets.

grafana_prometheus_request_duration_seconds = prometheus:histogram(
    "grafana_prometheus_request_duration_seconds", "Request duration down to the level of a panel",
    {"org_id", "source", "folder", "dashboard", "panel"},
    {0.1, 1, 2, 5, 10, 30})
