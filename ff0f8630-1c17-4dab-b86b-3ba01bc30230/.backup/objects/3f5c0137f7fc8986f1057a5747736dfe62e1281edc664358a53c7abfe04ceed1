local m, s, o

m = Map("network_scripts", "基础配置", "配置校园网认证与切换参数")

s = m:section(NamedSection, "network_switch", "switch", "系统设置")
s.anonymous = false
s.addremove = false

s:tab("general", "接口设置")
s:tab("time", "默认策略")
s:tab("advanced", "高级设置")

o = s:taboption("general", Value, "broadband_interface", "宽带逻辑接口")
o.default = "wan"; o.rmempty = false
o = s:taboption("general", Value, "broadband_device", "宽带物理设备")
o.default = "wan"
o = s:taboption("general", Value, "broadband_gateway", "宽带网关 IP")
o.datatype = "ip4addr"; o.default = "172.17.21.1"
o = s:taboption("general", Value, "cpe_interface", "CPE 逻辑接口")
o.default = "lan1"; o.rmempty = false
o = s:taboption("general", Value, "cpe_device", "CPE 物理设备")
o.default = "lan1"
o = s:taboption("general", Value, "cpe_gateway", "CPE 网关 IP")
o.default = "192.168.8.1"; o.datatype = "ip4addr"

o = s:taboption("time", Value, "broadband_start", "宽带开始时间"); o.default = "6"; o.datatype = "range(0,23)"
o = s:taboption("time", Value, "broadband_end", "宽带结束时间"); o.default = "24"; o.datatype = "range(1,24)"

o = s:taboption("advanced", Flag, "quality_check", "启用质量检测"); o.default = "1"
o = s:taboption("advanced", Value, "max_latency", "最大延迟 (ms)"); o:depends("quality_check", "1"); o.default = "200"
o = s:taboption("advanced", Value, "max_packet_loss", "最大丢包率 (%)"); o:depends("quality_check", "1"); o.default = "20"
o = s:taboption("advanced", Value, "boot_delay", "启动延迟"); o.default = "30"
o = s:taboption("advanced", ListValue, "log_level", "日志级别")
o:value("debug"); o:value("info"); o:value("warn"); o:value("error"); o.default = "info"

s2 = m:section(NamedSection, "campus_auth", "auth", "认证账号")
s2.anonymous = false
s2:tab("account", "账号设置")
s2:tab("server", "服务器设置")

o = s2:taboption("account", Value, "username", "主账号"); o.rmempty = false
o = s2:taboption("account", Value, "password", "主账号密码"); o.password = true
o = s2:taboption("account", Value, "username2", "备用账号")
o = s2:taboption("account", Value, "password2", "备用账号密码"); o.password = true

o = s2:taboption("server", Value, "wlanacip", "AC IP (劫持网关)")
o.default = "172.16.1.82"; o.description = "用于构建认证报文"
o = s2:taboption("server", Value, "wlanacname", "AC 名称")
o.default = "GXSTNU-BRAS"
o = s2:taboption("server", Value, "school_dns", "学校DNS服务器")
o.default = "172.20.0.203"; o.description = "用于解析真实认证服务器IP"
o = s2:taboption("server", Value, "auth_domain", "认证域名")
o.default = "auth.gxstnu.edu.cn"

return m