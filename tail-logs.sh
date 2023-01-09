docker logs -f --since=0s prometheus-grafana-nginx-lua-rev_proxy-1 \
  | jq -R -r '
     . as $line 
        | try (
            fromjson | with_entries(
                select(.key|match("(request_uri|request_method|grafana.*)";"i")))
          ) catch $line'
