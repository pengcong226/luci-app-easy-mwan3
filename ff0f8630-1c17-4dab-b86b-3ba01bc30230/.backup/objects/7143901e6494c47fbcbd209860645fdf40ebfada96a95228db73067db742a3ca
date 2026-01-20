module("luci.controller.network-scripts.index", package.seeall)

function index()
    entry({"admin", "services", "network-scripts"}, firstchild(), _("网络脚本管理"), 60).dependent = false
    entry({"admin", "services", "network-scripts", "status"}, call("action_status"), _("状态监控"), 10)
    entry({"admin", "services", "network-scripts", "config"}, cbi("network-scripts/config"), _("基础配置"), 20)
    entry({"admin", "services", "network-scripts", "schedule"}, cbi("network-scripts/schedule"), _("时间策略"), 25)
    entry({"admin", "services", "network-scripts", "notify"}, cbi("network-scripts/notify"), _("通知设置"), 28)
    entry({"admin", "services", "network-scripts", "logs"}, call("action_logs"), _("运行日志"), 30)
    entry({"admin", "services", "network-scripts", "history"}, call("action_history"), _("历史统计"), 35)
    entry({"admin", "services", "network-scripts", "control"}, call("action_control"), _("手动控制"), 40)
    
    entry({"admin", "services", "network-scripts", "api", "status"}, call("api_status")).leaf = true
    entry({"admin", "services", "network-scripts", "api", "lock"}, call("api_lock")).leaf = true
    entry({"admin", "services", "network-scripts", "api", "run"}, call("api_run")).leaf = true
    entry({"admin", "services", "network-scripts", "api", "quality"}, call("api_quality")).leaf = true
    entry({"admin", "services", "network-scripts", "api", "history"}, call("api_history")).leaf = true
end

function action_status() luci.template.render("network-scripts/status") end
function action_history() luci.template.render("network-scripts/history") end
function action_control() luci.template.render("network-scripts/control") end

function action_logs()
    local sys = require "luci.sys"
    local log_file = luci.http.formvalue("file") or "switch"
    local level = luci.http.formvalue("level") or "all"
    local path = "/var/log/network_scripts/network_switch.log"
    if log_file == "auth" then path = "/var/log/network_scripts/campus_auth.log"
    elseif log_file == "history" then path = "/var/log/network_scripts/history.log" end
    
    -- 安全优化：简单的 HTML 转义，防止日志里的怪字符破坏页面
    local function html_escape(s)
        return (string.gsub(s, "[<>&\"']", {
            ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;", ["\""] = """, ["'"] = "&#039;"
        }))
    end

    local cmd = "tail -n 200 " .. path
    if level ~= "all" then cmd = "grep -i '\\[" .. level:upper() .. "\\]' " .. path .. " | tail -n 200" end
    
    local raw_log = sys.exec(cmd .. " 2>/dev/null") or "暂无日志"
    luci.template.render("network-scripts/logs", { content = html_escape(raw_log), log_file = log_file, level = level })
end

function api_status()
    local sys = require "luci.sys"; local http = require "luci.http"; local fs = require "nixio.fs"
    
    -- 极速模式：直接读取 JSON 文件，不执行任何系统命令
    local state_file = "/tmp/network_scripts_state.json"
    local content = fs.readfile(state_file)
    
    if not content or content == "" then
        -- 如果文件不存在（守护进程还没跑起来），返回一个默认的离线状态
        http.prepare_content("application/json")
        http.write_json({
            gateway="unknown", device="unknown", internet="offline", 
            lock_mode="off", auth_status="unknown", mode="starting..."
        })
    else
        http.prepare_content("application/json")
        http.write(content)
    end
end

-- 既然 status 已经包含了 quality，这个接口其实可以废弃或者直接复用
function api_quality()
    api_status() 
end

function api_lock()
    local sys = require "luci.sys"; local http = require "luci.http"
    -- 锁定操作还是需要调用脚本，但这个不频繁，无所谓
    sys.exec("/usr/bin/network_switch.sh lock " .. (http.formvalue("mode") or "off") .. " " .. (http.formvalue("duration") or "0"))
    http.prepare_content("application/json"); http.write_json({success=true})
end

function api_run()
    local sys = require "luci.sys"; local http = require "luci.http"; local action = http.formvalue("action")
    if action == "test" then
        http.prepare_content("text/plain"); http.write(sys.exec("/usr/bin/network_switch.sh test 2>&1"))
    elseif action == "diagnose" then
        http.prepare_content("text/plain"); http.write(sys.exec("/usr/lib/network_scripts/campus_auth.sh diagnose 2>&1"))
    else
        local cmd = "/usr/bin/network_switch.sh"
        if action == "auth" then cmd = "/usr/lib/network_scripts/campus_auth.sh login"; elseif action == "logout" then cmd = "/usr/lib/network_scripts/campus_auth.sh logout" end
        -- 这里的 switch 不再直接运行，而是触发一次立即检测（如果需要的话，或者直接让守护进程自己跑）
        -- 为了兼容性，我们还是允许手动触发一次
        sys.exec(cmd .. " >/dev/null 2>&1 &")
        http.prepare_content("application/json"); http.write_json({success=true})
    end
end

function api_history()
    local sys = require "luci.sys"; local http = require "luci.http"
    -- 统计功能还是得调用 shell 计算，因为 lua 处理大文件比较慢
    local stats = sys.exec(". /usr/lib/network_scripts/common.sh && get_statistics " .. (http.formvalue("period") or "today"))
    local recent = sys.exec("tail -n 50 /var/log/network_scripts/history.log 2>/dev/null")
    http.prepare_content("application/json"); http.write('{"stats":' .. stats .. ',"recent":"' .. recent:gsub("\n", "\\n"):gsub('"', '\\"') .. '"}')
end