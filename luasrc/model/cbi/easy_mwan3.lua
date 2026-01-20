-- Easy MWAN3 Configurator (v2.1 Ultimate)
local fs = require "nixio.fs"
local sys = require "luci.sys"

local m = Map("easy_mwan3", translate("Easy MWAN3 Configurator"),
	translate("A simplified, intelligent interface for configuring MWAN3 Load Balancing with Hybrid Strategy support."))

-- Helper to get WAN interfaces
local wan_ifaces = {}
for _, iface in ipairs(sys.net.devices()) do
	if iface:match("^eth") or iface:match("^wan") or iface:match("^vlan") then
		wan_ifaces[#wan_ifaces+1] = iface
	end
end

s = m:section(TypedSection, "global", translate("Global Settings"))
s.anonymous = true

e = s:option(Flag, "enabled", translate("Enable Easy MWAN3"))
e.rmempty = false

-- Policy Mode
mode = s:option(ListValue, "mode", translate("Load Balancing Mode"))
mode:value("balance", translate("Balanced (Weighted)"))
mode:value("failover", translate("Failover (Active/Backup)"))
mode.default = "balance"

-- Member Interfaces
members = s:option(MultiValue, "members", translate("Participating Interfaces"))
for _, iface in ipairs(wan_ifaces) do
	members:value(iface, iface:upper())
end
members.widget = "checkbox"

-- Advanced Rules Section
s2 = m:section(TypedSection, "rule", translate("Advanced Device Policies"))
s2.template = "cbi/tblsection"
s2.anonymous = true
s2.addremove = true

src = s2:option(Value, "src_ip", translate("Source IP/Device"))
src.datatype = "ipaddr"
-- Try to populate with DHCP leases
local leases = io.popen("cat /tmp/dhcp.leases")
if leases then
	for line in leases:lines() do
		local mac, ip, name = line:match("%d+ (%S+) (%S+) (%S+) %S+")
		if ip and name then
			src:value(ip, name .. " (" .. ip .. ")")
		end
	end
	leases:close()
end

policy = s2:option(ListValue, "policy", translate("Policy"))
policy:value("default", translate("Default (Follow Global)"))
policy:value("wan_only", translate("Force WAN Only"))
policy:value("wan2_only", translate("Force WAN2 Only"))

return m
