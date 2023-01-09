-- To be used with 'content_by_lua_file' directive.

ngx.say("Folder/Dashboard Lookup")

for _, key in ipairs(ngx.shared.grafana_dashboard_names:get_keys()) do
    local info = cjson.decode(ngx.shared.grafana_dashboard_names:get(key))
    ngx.say(string.format("  %-40s   %s/%s", key, info.folder_title, info.dashboard_title))
end

ngx.say("Folder/Dashboard/Panel Lookup")

for _, key in ipairs(ngx.shared.grafana_dashboard_panel_names:get_keys()) do
    local info = cjson.decode(ngx.shared.grafana_dashboard_panel_names:get(key))
    ngx.say(string.format("  %-40s   %s/%s/%s", key, info.folder_title, info.dashboard_title, info.panel_title))
end
