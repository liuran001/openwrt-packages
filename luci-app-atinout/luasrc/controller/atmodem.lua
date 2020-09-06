module("luci.controller.atmodem", package.seeall)
local http = require("luci.http")
function index()
	entry({"admin", "modem"},  firstchild(), translate("Modem"), 45).dependent = false
    entry({"admin", "modem", "command"}, template("modem/command"), translate("AT-Command"), 12).leaf = true
    entry({"admin", "modem", "webcmd"}, call("webcmd"))
end

function webcmd()
    local cmd = http.formvalue("cmd")
    if cmd then
	    local at = io.popen("/usr/bin/at " ..cmd:gsub("[$]", "\\\$"):gsub("\"", "\\\"").." 2>&1")
	    local result =  at:read("*a")
	    at:close()
        http.write(tostring(result))
    else
        http.write_json(http.formvalue())
    end
end
