require "nixio.fs"
local m, s, o

function sync_value_to_file(file, value)
	value = value:gsub("\r\n?", "\n")
	local old_value = nixio.fs.readfile(file)
	if value ~= old_value then
		nixio.fs.writefile(file, value)
	end
end

m = Map("chinadns-ng", translate(""))

s = m:section(TypedSection, "chinadns-ng", translate("Route Setting"))
s:tab("blacklist", translate("Black List"))
s:tab("whitelist", translate("White List"))
s.addremove = false
s.anonymous = true


o = s:taboption("blacklist", Value, "gfwlist_file",
	translate("Use GFWRoute File"),
	translate("Choose black domain list file, Domains in black list will use trusted DNS servers. You can choose one of these or use any other file:")
		..[[<br />/etc/chinadns-ng/gfwlist.txt ]]
		..translate("(default GFWRoute list, can be updated automaticly. If you use SSR+, don't use gfwlist file for black list.)")
		..[[<br />/etc/chinadns-ng/blacklist.txt ]]
		..translate("(custom GFWRoute list, you can edit it below)")
	)
	o.placeholder = "/etc/chinadns-ng/blacklist.txt"
	o.default     = "/etc/chinadns-ng/blacklist.txt"
	o.datatype    = "file"
	o.rmempty     = false

local blacklist = "/etc/chinadns-ng/blacklist.txt"
o = s:taboption("blacklist", TextValue, "blacklist",
	translate("Custom GFWRoute List (Black Domain List)"),
	translate("Edit the content of custom black domain list file (/etc/chinadns-ng/blacklist.txt)"))
	o.rows = 13
	o.wrap = "off"
	o.rmempty = true

	o.cfgvalue = function(self, section)
		return nixio.fs.readfile(blacklist) or " "
	end
	o.write = function(self, section, value)
		sync_value_to_file(blacklist, value)
	end
	o.remove = function(self, section, value)
		nixio.fs.writefile(blacklist, "")
	end


o = s:taboption("whitelist", Value, "chnlist_file",
	translate("Use CHNRoute File"),
	translate("Choose white domain list file, domains in white list will use China DNS servers. You can choose one of these or use any other file:")
		..[[<br />/etc/chinadns-ng/chinalist.txt ]]
		..translate("(default CHNRoute list, can be updated automaticly)")
		..[[<br />/etc/chinadns-ng/whitelist.txt ]]
		..translate("(custom CHNRoute list, you can edit it below)")
	)
	o.placeholder = "/etc/chinadns-ng/whitelist.txt"
	o.default     = "/etc/chinadns-ng/whitelist.txt"
	o.datatype    = "file"
	o.rmempty     = false

local whitelist = "/etc/chinadns-ng/whitelist.txt"
o = s:taboption("whitelist", TextValue, "whitelist",
	translate("Custom CHNRoute List (White Domain List)"),
	translate("Edit the content of custom white domain list file (/etc/chinadns-ng/whitelist.txt)"))
	o.rows = 13
	o.wrap = "off"
	o.rmempty = true

	o.cfgvalue = function(self, section)
		return nixio.fs.readfile(whitelist) or " "
	end
	o.write = function(self, section, value)
		sync_value_to_file(whitelist, value)
	end
	o.remove = function(self, section, value)
		nixio.fs.writefile(whitelist, "")
	end

return m
