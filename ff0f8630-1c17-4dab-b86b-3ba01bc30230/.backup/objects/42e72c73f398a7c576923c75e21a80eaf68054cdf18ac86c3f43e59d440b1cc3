-- 加载配置映射
m = Map("schoolnet", translate("School Network Authentication"), translate("Configure your school network authentication settings here."))

-- 创建一个 Section，对应配置文件中的 config schoolnet 'base'
s = m:section(NamedSection, "base", "schoolnet", translate("Basic Settings"))
s.anonymous = true
s.addremove = false

-- 启用/禁用 开关
e = s:option(Flag, "enabled", translate("Enable"))
e.rmempty = false

-- 账号输入框
u = s:option(Value, "username", translate("Username"))
u.description = translate("Your student ID or account name.")
u.rmempty = false

-- 密码输入框 (密码类型，显示为星号)
p = s:option(Value, "password", translate("Password"))
p.password = true
p.rmempty = false

-- 运营商选择 (下拉菜单示例，如果需要的话)
isp = s:option(ListValue, "isp", translate("ISP"))
isp:value("telecom", translate("China Telecom"))
isp:value("unicom", translate("China Unicom"))
isp:value("mobile", translate("China Mobile"))
isp:value("campus", translate("Campus Network"))
isp.default = "campus"

return m