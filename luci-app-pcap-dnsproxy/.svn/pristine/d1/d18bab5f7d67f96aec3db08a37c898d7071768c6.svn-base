-- Copyright 2017-2018 Dirk Brenken (dev@brenken.org)
-- Copyright 2020 muink <https://github.com/muink>
-- This is free software, licensed under the Apache License, Version 2.0

local m, s, o

local fs	= require("nixio.fs")
local sys	= require("luci.sys")
local util	= require("luci.util")
local uci = require("luci.model.uci").cursor()
local input	= "/etc/pcap-dnsproxy/Config.conf-opkg"
local output = "/etc/pcap-dnsproxy/Config.conf"
local userin   = "/etc/pcap-dnsproxy/user/Config"

m = SimpleForm("pcap-dnsproxy", nil,
	translate("This form allows you to modify the content of the main pcap-dnsproxy configuration file")
	.. "<br/>"
	.. translatef("For further information "
		.. "<a href=\"%s\" target=\"_blank\">"
		.. "check the online documentation</a>", translate("https://github.com/wongsyrone/Pcap_DNSProxy/blob/master/Documents/ReadMe.en.txt")))
m:append(Template("pcap-dnsproxy/css"))
m.submit = false
m.reset = false

s = m:section(Table, {{user, system}})

o = s:option(Value, "user")
o.template = "cbi/tvalue"
o.description = translatef("User config file: <code>%s</code>", userin)
o.rows = 20
function o.cfgvalue()
	local v = fs.readfile(userin) or translate("File does not exist.") .. translatef(" Please check your configuration or reinstall %s.", "luci-app-pcap-dnsproxy")
	return util.trim(v) ~= "" and v or translate("Empty file.")
end
function o.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	fs.writefile(userin, value)
end
function o.remove(self, section, value)
	return fs.writefile(userin, "")
end

o = s:option(Value, "system")
o.template = "cbi/tvalue"
o.description = translatef("System config file: <code>%s</code>", output)
o.rows = 20
o.readonly = true
function o.cfgvalue()
	local v = fs.readfile(output) or translate("File does not exist.") .. translatef(" Please check your configuration or reinstall %s.", "pcap-dnsproxy")
	return util.trim(v) ~= "" and v or translate("Empty file.")
end
function s.handle(self, state, data)
	return true
end


s = m:section(SimpleSection)

save = s:option(Button, "_save") 
save.inputtitle = translate("Save")
save.inputstyle = "save"
save.write = function()
	uci:commit("pcap-dnsproxy")
	sys.call ("/usr/bin/pcap-dnsproxy.sh userconf_full")
end

return m
