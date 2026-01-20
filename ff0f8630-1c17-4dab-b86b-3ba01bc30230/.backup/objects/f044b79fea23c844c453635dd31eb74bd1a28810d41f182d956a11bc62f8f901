module("luci.controller.easy_mwan3.index", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/easy_mwan3") then
        return
    end

    entry({"admin", "network", "easy_mwan3"}, cbi("easy_mwan3/client"), _("MWAN3 极简助手"), 60).dependent = true
end