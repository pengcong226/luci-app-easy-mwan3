module("luci.controller.easy_mwan3", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/mwan3") then
		return
	end

	local page = entry({"admin", "network", "easy_mwan3"}, cbi("easy_mwan3"), _("Easy MWAN3"), 60)
	page.dependent = true
end
