module("luci.controller.chinadns-ng", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/chinadns-ng") then
		return
	end
	entry({"admin", "services", "chinadns-ng"}, cbi("chinadns-ng"), _("ChinaDNS-NG"), 70).dependent = true
end
