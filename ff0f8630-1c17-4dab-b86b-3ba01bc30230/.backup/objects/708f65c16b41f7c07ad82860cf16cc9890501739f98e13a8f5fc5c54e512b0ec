local fs = require "nixio.fs"

m = Map("network_scripts", translate("网络智能切换 v3.0 Pro"),
    translate("自动监测网络质量并在宽带与 CPE 之间智能切换。<br/>") ..
    translate("当前状态由守护进程每 10 秒更新一次。"))

-- Tab 定义
m:section(SimpleSection).template = "network_scripts/status"

s = m:section(NamedSection, "network_switch", "network_switch", translate("核心设置"))
s.anonymous = true
s.addremove = false

-- 选项卡：基本设置
s:tab("basic", translate("基本设置"))
s:tab("advanced", translate("高级设置"))
s:tab("notification", translate("通知设置"))

-- 基本设置
o = s:taboption("basic", Flag, "enabled", translate("启用插件"))
o.rmempty = false

o = s:taboption("basic", ListValue, "broadband_interface", translate("宽带接口"))
for _, iface in ipairs(luci.sys.net.devices()) do
    if iface ~= "lo" then o:value(iface) end
end
o.default = "wan"
o.description = translate("通常是 eth0 或 wan")

o = s:taboption("basic", ListValue, "cpe_interface", translate("CPE 接口"))
for _, iface in ipairs(luci.sys.net.devices()) do
    if iface ~= "lo" then o:value(iface) end
end
o.default = "lan1"
o.description = translate("连接 4G/5G CPE 的接口")

o = s:taboption("basic", Value, "cpe_gateway", translate("CPE 网关 IP"))
o.datatype = "ipaddr"
o.default = "192.168.8.1"

-- 高级设置
o = s:taboption("advanced", Value, "check_interval", translate("检测间隔 (秒)"))
o.datatype = "uinteger"
o.default = "10"
o.description = translate("守护进程轮询的时间间隔，越短反应越快但负载越高")

o = s:taboption("advanced", Flag, "quality_check", translate("启用质量检测"))
o.default = "1"
o.description = translate("不仅检查连通性，还检查延迟和丢包率")

o = s:taboption("advanced", Value, "latency_threshold", translate("延迟阈值 (ms)"))
o.datatype = "uinteger"
o.default = "100"
o:depends("quality_check", "1")

-- 通知设置
o = s:taboption("notification", Flag, "notify_switch", translate("切换通知"))
o.default = "0"

o = s:taboption("notification", Value, "dingtalk_webhook", translate("钉钉 Webhook"))
o:depends("notify_switch", "1")

return m