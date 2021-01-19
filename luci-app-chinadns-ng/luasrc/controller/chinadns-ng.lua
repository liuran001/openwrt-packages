module("luci.controller.chinadns-ng", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/chinadns-ng") then
		return
	end

	entry({"admin", "services", "chinadns-ng"}, alias("admin", "services", "chinadns-ng", "basic"), _("ChinaDNS-NG"), 70).dependent = true
	entry({"admin", "services", "chinadns-ng", "basic"}, cbi("chinadns-ng/basic"), _("General Setting"), 80).leaf = true
	entry({"admin", "services", "chinadns-ng", "routes"}, cbi("chinadns-ng/routes"), _("Route Setting"), 90).leaf = true
	entry({"admin", "services", "chinadns-ng", "update"}, cbi("chinadns-ng/update"), _("Rules Update"), 99).leaf = true
	entry({"admin", "services", "chinadns-ng", "status"}, call("act_status")).leaf = true
	entry({"admin", "services", "chinadns-ng", "refresh"}, call("refresh_data"))
end

function act_status()
	local e={}
	e.running=luci.sys.call("ps|grep -v grep|grep -c chinadns-ng >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function refresh_data()
	sret=luci.sys.call("/usr/share/chinadns-ng/chinadns-ng_update.sh 2>/dev/null")
	if sret== 0 then
		retstring ="0"
	else
		retstring ="-1"
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json({ ret=retstring})
end

-- Fuck GFW and who made it, Freedom!