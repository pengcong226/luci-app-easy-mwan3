local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local fs = require "nixio.fs"

m = Map("easy_mwan3", translate("MWAN3 极简配置助手 v2.1 Ultimate"),
    translate("一键生成企业级多WAN策略，支持混合策略引擎。<br/>") ..
    translate("<b style='color:red'>警告：应用配置将完全覆盖现有的 MWAN3 设置！</b>"))

m.on_after_commit = function(self)
    sys.call("/usr/bin/easy_mwan3_gen.sh restart >/dev/null 2>&1 &")
end

-- Tab 定义
s = m:section(NamedSection, "global", "global", translate("全局设置"))
s.anonymous = true
s:tab("basic", translate("基础策略"))
s:tab("advanced", translate("高级功能"))

-- Tab: Basic
o = s:taboption("basic", Flag, "enabled", translate("启用插件"))
o.rmempty = false

o = s:taboption("basic", ListValue, "mode", translate("默认全局模式"))
o:value("balance", translate("负载均衡 (所有接口叠加)"))
o:value("failover", translate("故障转移 (按优先级切换)"))
o.default = "balance"
o.description = translate("未匹配规则的设备将使用此模式。特定设备可在下方单独指定模式。")

o = s:taboption("basic", Value, "check_ip", translate("连通性检测 IP"))
o.default = "223.5.5.5"
o.datatype = "ipaddr"

-- Tab: Advanced
o = s:taboption("advanced", Flag, "sticky_https", translate("HTTPS 粘滞"))
o.default = "1"
o.description = translate("强制 HTTPS (443) 流量保持 IP 不变，防止网银/游戏掉线。")

o = s:taboption("advanced", Flag, "sticky_source", translate("源地址粘滞"))
o.default = "0"
o.description = translate("激进模式：同一台设备的所有流量在超时前锁定同一出口。")

o = s:taboption("advanced", Value, "sticky_timeout", translate("粘滞超时 (秒)"))
o.default = "600"
o.datatype = "uinteger"
o:depends("sticky_source", "1")


-- Section: 接口设置
s_if = m:section(TypedSection, "interface", translate("物理接口定义"))
s_if.template = "cbi/tblsection"
s_if.anonymous = true
s_if.addremove = true
s_if.sortable = true

o = s_if:option(ListValue, "interface", translate("网络接口"))
uci:foreach("network", "interface", function(s)
    if s[".name"] ~= "loopback" and s[".name"] ~= "lan" and s[".name"] ~= "global" then
        o:value(s[".name"])
    end
end)
o.rmempty = false

o = s_if:option(Value, "weight", translate("权重 (均衡模式)"))
o.datatype = "uinteger"
o.default = "1"

o = s_if:option(Value, "metric", translate("优先级 (主备模式)"))
o.datatype = "uinteger"
o.default = "10"
o.description = translate("数值越小优先级越高")


-- Section: 设备分流规则
s_dev = m:section(TypedSection, "device_rule", translate("设备分流策略 (混合引擎)"))
s_dev.template = "cbi/tblsection"
s_dev.anonymous = true
s_dev.addremove = true
s_dev.sortable = true
s_dev.description = translate("指定设备强制使用特定模式或接口，不受全局模式影响。")

o = s_dev:option(Value, "name", translate("备注"))

-- MAC 选择器增强版：合并 ARP 和 DHCP Leases
o = s_dev:option(Value, "mac", translate("设备 (MAC)"))
o.datatype = "macaddr"
local mac_list = {}
-- 1. 读取 DHCP Leases
local lease_file = "/tmp/dhcp.leases"
if fs.access(lease_file) then
    for line in io.lines(lease_file) do
        local ts, mac, ip, name = line:match("^(%d+)%s+(%S+)%s+(%S+)%s+(%S+)")
        if mac then
            name = name or "Unknown"
            mac_list[mac] = name .. " (" .. ip .. ")"
        end
    end
end
-- 2. 补充 ARP 缓存
sys.net.mac_hints(function(mac, name)
    if not mac_list[mac] then
        mac_list[mac] = name
    end
end)
-- 3. 填充列表
for mac, info in pairs(mac_list) do
    o:value(mac, mac .. " - " .. info)
end

o = s_dev:option(Value, "src_ip", translate("源 IP (可选)"))
o.datatype = "ipaddr"

o = s_dev:option(ListValue, "target_policy", translate("策略模式"))
o:value("default", translate("跟随全局默认"))
o:value("force_balance", translate("★ 强制负载均衡 (叠加)"))
o:value("force_failover", translate("★ 强制故障转移 (主备)"))
uci:foreach("easy_mwan3", "interface", function(s)
    if s.interface then
        o:value(s.interface, "只走接口: " .. s.interface)
    end
end)
o.rmempty = false


-- Section: 目标分流规则
s_dst = m:section(TypedSection, "dest_rule", translate("目标分流策略"))
s_dst.template = "cbi/tblsection"
s_dst.anonymous = true
s_dst.addremove = true
s_dst.sortable = true

o = s_dst:option(Value, "name", translate("备注"))

o = s_dst:option(Value, "dest_ip", translate("目标 IP/网段"))
o.datatype = "string"

o = s_dst:option(ListValue, "target_policy", translate("策略模式"))
o:value("default", translate("跟随全局默认"))
o:value("force_balance", translate("★ 强制负载均衡"))
o:value("force_failover", translate("★ 强制故障转移"))
uci:foreach("easy_mwan3", "interface", function(s)
    if s.interface then
        o:value(s.interface, "只走接口: " .. s.interface)
    end
end)

return m
