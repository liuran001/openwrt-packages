-- Copyright 2017-2018 Dirk Brenken (dev@brenken.org)
-- Copyright 2020 muink <https://github.com/muink>
-- This is free software, licensed under the Apache License, Version 2.0

local m, s, o

local fs    = require("nixio.fs")
local sys	= require("luci.sys")
local util  = require("luci.util")
local input    = "/etc/pcap-dnsproxy/Hosts.conf-opkg"
local output = "/etc/pcap-dnsproxy/Hosts.conf"
local userin   = "/etc/pcap-dnsproxy/user/Hosts"

m = SimpleForm("pcap-dnsproxy", nil,
	translate("This form allows you to modify the content of the pcap-dnsproxy Hosts config file")
	.. "<br/>"
	.. translatef("For further information "
		.. "<a href=\"%s\" target=\"_blank\">"
		.. "check the online documentation</a>", translate("https://github.com/wongsyrone/Pcap_DNSProxy/blob/master/Documents/ReadMe.en.txt#L706")))
m:append(Template("pcap-dnsproxy/css"))
m.submit = translate("Save")
m.reset = false

--usrcfg

s = m:section(SimpleSection, nil, translatef("System config file: <code>%s</code>", output))

o = s:option(TextValue, "system")
o.rows = 20

function o.cfgvalue()
	local v = fs.readfile(output) or translate("File does not exist.") .. translatef(" Please check your configuration or reinstall %s.", "pcap-dnsproxy")
	return util.trim(v) ~= "" and v or translate("Empty file.")
end

function o.write(self, section, system)
	fs.writefile(output, "\n" .. util.trim(system:gsub("\r\n", "\n")) .. "\n")
end

function o.remove(self, section, value)
	return fs.writefile(output, "")
end

function s.handle(self, state, data)
	return true
end

return m
