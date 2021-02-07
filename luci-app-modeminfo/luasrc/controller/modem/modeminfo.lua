local nixio = require "nixio"

module("luci.controller.modem.modeminfo", package.seeall)

local utl = require "luci.util"

function index()
	entry({"admin", "modem"},  firstchild(), translate("Modem"), 45).dependent = false
	entry({"admin", "modem", "main"},  alias ("admin", "modem", "main", "main"), translate("Signal Overview"), 10)
	entry({"admin", "modem", "main", "main"}, template("modem/modeminfo"), translate("Overview"), 51)
	entry({"admin", "modem", "main", "config"}, cbi("modem/modeminfo"), translate("Setup"), 52)
	entry({"admin", "modem", "data"}, call("get_data")).leaf = true
end


function get_data()
	local fs = require "nixio.fs"
	local data = luci.sys.exec("modeminfo")
	luci.http.prepare_content("application/json")
	luci.http.write(data)
end
