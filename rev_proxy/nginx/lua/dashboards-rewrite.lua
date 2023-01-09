-- Use with 'rewrite_by_lua_file' directive

if ngx.is_subrequest then
    -- we don't want this Lua code to be active in the subrequest, just
    -- because its the same location; otherwise we get a subrequest loop.
    return -- ngx.exit(ngx.OK)
end

local res = ngx.location.capture(ngx.var.request_uri,
    { method = ngx.HTTP_GET, copy_all_vars = true })

if res.status == ngx.HTTP_OK and res.truncated == false then

    local model = cjson.decode(res.body)

    local dashboard_id = model.dashboard.id
    local dashboard_uid = model.dashboard.uid
    local dashboard_title = model.dashboard.title
    local folder_title = model.meta.folderTitle

    local org_id = ngx.var.http_x_grafana_org_id

    local dashboard_id_lookup_key
    local dashboard_uid_lookup_key

    local info = {}
    info.folder_title = folder_title
    info.dashboard_title = dashboard_title
    local infojson = cjson.encode(info)

    if dashboard_id then -- Grafana 7
        dashboard_id_lookup_key = "org_id=" .. org_id .. "|id=" .. dashboard_id
        local success, err, forcible = ngx.shared.grafana_dashboard_names:set(
            dashboard_id_lookup_key, infojson)
        if not success then
            print("ngx.shared.grafana_dashboard_names:set failed for ", dashboard_id_lookup_key, ": ", err)
        end
    end

    -- Need both id and uid; not either/or

    if dashboard_uid then -- Grafana 9
        dashboard_uid_lookup_key = "org_id=" .. org_id .. "|uid=" .. dashboard_uid
        local success, err, forcible = ngx.shared.grafana_dashboard_names:set(
            dashboard_uid_lookup_key, infojson)
        if not success then
            print("ngx.shared.grafana_dashboard_names:set failed for ", dashboard_uid_lookup_key, ": ", err)
        end
    end
    
    ngx.var.grafana_dashboard_title = dashboard_title
    ngx.var.grafana_folder_title = folder_title

    for i, panel in pairs(model.dashboard.panels) do
        local panel_title = panel.title
        local panel_id = panel.id

        info.panel_title = panel_title
        infojson = cjson.encode(info)

        if dashboard_id then
            local panel_lookup_key = dashboard_id_lookup_key .. "|panel_id=" .. panel_id
            local success, err, forcible = ngx.shared.grafana_dashboard_panel_names:set(
                panel_lookup_key, infojson, 600)
        end
        if dashboard_uid then
            local panel_lookup_key = dashboard_uid_lookup_key .. "|panel_id=" .. panel_id
            local success, err, forcible = ngx.shared.grafana_dashboard_panel_names:set(
                panel_lookup_key, infojson, 600)
        end
    end
end