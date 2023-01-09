-- Use this as a 'rewrite_by_lua_file' directive.
--
-- Enrich with username ('login') from Grafana
--

local session_cookie_name = ngx.var.grafana_auth_login_cookie_name
local session_cookie_value = ngx.var["cookie_" .. session_cookie_name]

local session_key = session_cookie_name .. "|" .. session_cookie_value
local username = ngx.shared.grafana_sessions:get(session_key)

if username == nil then

    local res = ngx.location.capture("/api/user",
        { method = ngx.HTTP_GET, copy_all_vars = true })

    if res.status == ngx.HTTP_OK and res.truncated == false then
        
        local resp_doc = cjson.decode(res.body)
        username = resp_doc["login"]

        local success, err, forcible = ngx.shared.grafana_sessions:set(
            session_key, username, 60)

    else
        print(
            "Lookup for /api/user returned ", res.status,
            " with truncated=", res.truncated,
            ". Body is as follows:\n", res.body)
        
        ngx.shared.grafana_sessions:set(session_key, "ERROR", 60) -- negative cache
    end
end

if username then
    ngx.var.grafana_username = username
end

--
-- Enrich with Dashboard and Panel Titles
--

local org_id = ngx.var.http_x_grafana_org_id
local dashboard_id = ngx.var.http_x_dashboard_id
local dashboard_uid = ngx.var.http_x_dashboard_uid
local panel_id = ngx.var.http_x_panel_id

if dashboard_id or dashboard_uid then

    local dashboard_lookup_key

    if dashboard_id then
        dashboard_lookup_key = "org_id=" .. org_id .. "|id=" .. dashboard_id
    elseif dashboard_uid then
        dashboard_lookup_key = "org_id=" .. org_id .. "|uid=" .. dashboard_uid
    end

    local info = ngx.shared.grafana_dashboard_names:get(dashboard_lookup_key)
    if info then
        info = cjson.decode(info)
    end

    ngx.var.grafana_folder_title = info and info.folder_title or ""
    ngx.var.grafana_dashboard_title = info and info.dashboard_title or ""

    if panel_id then
        local panel_lookup_key = dashboard_lookup_key .. "|panel_id=" .. panel_id
        local info = ngx.shared.grafana_dashboard_panel_names:get(panel_lookup_key)
        if info then
            info = cjson.decode(info)
        end

        ngx.var.grafana_panel_title = info and info.panel_title or ""
    else
        ngx.var.grafana_panel_title = ""
    end
else
    ngx.var.grafana_dashboard_title = ""
end
