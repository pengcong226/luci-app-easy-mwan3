local m, s, o
m = Map("network_scripts", "时间策略")
s = m:section(TypedSection, "schedule", "自定义时段")
s.anonymous = false
s.addremove = true
s.template = "cbi/tblsection"
o = s:option(Flag, "enabled", "启用"); o.default = "0"; o.width="10%"
o = s:option(Value, "start", "开始"); o.datatype="range(0,23)"; o.width="20%"
o = s:option(Value, "end", "结束"); o.datatype="range(0,24)"; o.width="20%"
o = s:option(ListValue, "use", "线路"); o:value("broadband"); o:value("cpe"); o.width="20%"
return m