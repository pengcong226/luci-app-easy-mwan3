module("luci.controller.schoolnet.schoolnet", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/schoolnet") then
        return
    end

    -- 创建菜单入口：服务 -> 校园网认证
    -- 这里的 50 是排序权重
    entry({"admin", "services", "schoolnet"}, cbi("schoolnet/schoolnet"), _("School Net Auth"), 50).dependent = true
end