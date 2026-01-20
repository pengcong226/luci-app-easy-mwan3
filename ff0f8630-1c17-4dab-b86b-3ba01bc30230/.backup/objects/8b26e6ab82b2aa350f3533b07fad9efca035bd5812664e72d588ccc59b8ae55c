local m, s, o
m = Map("network_scripts", "通知设置")
s = m:section(NamedSection, "notification", "notify", "钉钉机器人设置")
s.anonymous = false
s:tab("basic", "基本设置")
s:tab("trigger", "触发条件")
o = s:taboption("basic", Flag, "enabled", "启用通知"); o.default = "0"
o = s:taboption("basic", Value, "dingtalk_webhook", "Webhook 地址")
o = s:taboption("basic", Value, "dingtalk_secret", "加签密钥"); o.password = true
o = s:taboption("trigger", Flag, "notify_auth_fail", "认证失败时通知"); o.default = "1"
o = s:taboption("trigger", Flag, "notify_switch", "线路切换时通知"); o.default = "0"
o = s:taboption("trigger", Flag, "notify_offline", "网络离线时通知"); o.default = "1"
return m