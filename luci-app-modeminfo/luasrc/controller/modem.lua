local nixio = require "nixio"

module("luci.controller.modem", package.seeall)

local utl = require "luci.util"

function index()
	entry({"admin", "modem"},  firstchild(), translate("Modem"), 45).dependent = false
	entry({"admin", "modem", "main"}, template("modem/main"), translate("Modem overview"), 10).leaf = true
	entry({"admin", "modem", "data"}, call("get_data")).leaf = true
end


function get_data()
	local fs = require "nixio.fs"
	local data = luci.sys.exec("modeminfo")
	luci.http.prepare_content("application/json")
	luci.http.write(data)
end