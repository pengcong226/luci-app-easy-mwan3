module("luci.controller.network_scripts.index", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/network_scripts") then
        return
    end

    local page = entry({"admin", "services", "network_scripts"}, cbi("network_scripts/client"), _("网络智能切换"), 60)
    page.dependent = true
    
    entry({"admin", "services", "network_scripts", "status"}, call("action_status"))
    entry({"admin", "services", "network_scripts", "switch"}, call("action_switch"))
    entry({"admin", "services", "network_scripts", "lock"}, call("action_lock"))
    entry({"admin", "services", "network_scripts", "log"}, call("action_log"))
    entry({"admin", "services", "network_scripts", "history"}, call("action_history"))
end

function action_status()
    local fs = require "nixio.fs"
    local json = require "luci.jsonc"
    
    local state_file = "/tmp/network_scripts_state.json"
    local data = {}
    
    if fs.access(state_file) then
        local content = fs.readfile(state_file)
        if content then
            data = json.parse(content) or {}
        end
    end
    
    -- 如果守护进程没跑，或者文件不存在，返回默认值
    if not next(data) then
        data = {
            status = "unknown",
            mode = "daemon_stopped",
            updated_at = 0
        }
    end
    
    luci.http.prepare_content("application/json")
    luci.http.write_json(data)
end

function action_switch()
    local target = luci.http.formvalue("target")
    if target == "broadband" or target == "cpe" then
        -- 异步调用，不阻塞页面
        luci.sys.call("/usr/bin/network_switch.sh lock " .. target .. " 0 &")
        luci.http.status(200, "OK")
        luci.http.write_json({result="ok"})
    else
        luci.http.status(400, "Bad Request")
    end
end

function action_lock()
    local mode = luci.http.formvalue("mode")
    local duration = luci.http.formvalue("duration") or "0"
    
    if mode == "broadband" or mode == "cpe" or mode == "off" then
        luci.sys.call("/usr/bin/network_switch.sh lock " .. mode .. " " .. duration .. " &")
        luci.http.status(200, "OK")
        luci.http.write_json({result="ok"})
    else
        luci.http.status(400, "Bad Request")
    end
end

function action_log()
    local fs = require "nixio.fs"
    local log_file = "/var/log/network_scripts/network_switch.log"
    local content = ""
    
    if fs.access(log_file) then
        -- 只读取最后 100 行
        content = luci.sys.exec("tail -n 100 " .. log_file)
    else
        content = "日志文件不存在"
    end
    
    luci.http.prepare_content("text/plain")
    luci.http.write(content)
end

function action_history()
    local fs = require "nixio.fs"
    local history_file = "/var/log/network_scripts/history.log"
    local content = ""
    
    if fs.access(history_file) then
        content = luci.sys.exec("tail -n 50 " .. history_file .. " | sort -r")
    else
        content = ""
    end
    
    luci.http.prepare_content("text/plain")
    luci.http.write(content)
end