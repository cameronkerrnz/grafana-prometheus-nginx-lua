-- Use with log_by_lua_file

--[[
    Prometheus treats empty strings as labels that aren't present at all.
    We want to ensure that metrics have a consistent set of labels so they
    can be usefully aggregated. So instead of emitting a label value
    of "", in Prometheus we use a token label value of "-".
]]

local org_id = ngx.var.http_x_grafana_org_id or "-"
local source = ngx.var.grafana_source or "-"
local folder_title = ngx.var.grafana_folder_title or "-"
if folder_title == "" then folder_title = "-" end
local dashboard_title = ngx.var.grafana_dashboard_title or "-"
if dashboard_title == "" then dashboard_title = "-" end
local panel_title = ngx.var.grafana_panel_title or "-"
if panel_title == "" then panel_title = "-" end

grafana_prometheus_request_duration_seconds:observe(
    tonumber(ngx.var.request_time), 
    {org_id, source, folder_title, dashboard_title, panel_title})
