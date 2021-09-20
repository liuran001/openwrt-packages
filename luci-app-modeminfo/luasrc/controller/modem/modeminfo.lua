local nixio = require "nixio"

module("luci.controller.modem.modeminfo", package.seeall)

local utl = require "luci.util"

function index()
	entry({"admin", "modem"},  firstchild(), translate("Modem"), 45).dependent = false
	entry({"admin", "modem", "main"},  alias ("admin", "modem", "main", "main"), translate("Modeminfo"), 10)
	entry({"admin", "modem", "main", "main"}, template("modem/modeminfo"), translate("Network"), 51)
	entry({"admin", "modem", "main", "hw"}, template("modem/modeminfohw"), translate("Hardware"), 52)
	entry({"admin", "modem", "main", "config"}, cbi("modem/modeminfo"), translate("Setup"), 53)
	entry({"admin", "modem", "data"}, call("get_data"))
end


function get_data()
	local fs = require "nixio.fs"
	local data = luci.sys.exec("/usr/bin/modeminfo")
	luci.http.prepare_content("application/json")
	luci.http.write(data)
end


