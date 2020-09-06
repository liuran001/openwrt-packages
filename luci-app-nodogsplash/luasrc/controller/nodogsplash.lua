
module("luci.controller.nodogsplash", package.seeall)

function index()
	if not nixio.fs.access("/usr/bin/nodogsplash") then
		return
	end
	
	entry ({"admin", "services", "nodogsplash"}, cbi ("nodogsplash"), _("WiFi portal"),20).dependent = true
	entry({"admin","services","nodogsplash","status"},call("act_status")).leaf=true
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep nodogsplash >/dev/null")==0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end