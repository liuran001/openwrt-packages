local m, s, o

if luci.sys.call("pidof chinadns-ng >/dev/null") == 0 then
	m = Map("chinadns-ng", translate("ChinaDNS-NG"), "%s - %s" %{translate("ChinaDNS-NG"), translate("RUNNING")})
else
	m = Map("chinadns-ng", translate("ChinaDNS-NG"), "%s - %s" %{translate("ChinaDNS-NG"), translate("NOT RUNNING")})
end

s = m:section(TypedSection, "chinadns-ng", translate("General Setting"))
s.anonymous   = true

o = s:option(Flag, "enable", translate("Enable"))
o.rmempty     = false

o = s:option(Flag, "fair_mode",
	translate("Enable the Fair_Mode"),
	translate("Enable the Fair_Mode or use the Compete_Mode"))
o.rmempty     = false

o = s:option(Value, "bind_port", translate("Listen Port"))
o.placeholder = 5353
o.default     = 5353
o.datatype    = "port"
o.rmempty     = false

o = s:option(Value, "bind_addr", translate("Listen Address"))
o.placeholder = "0.0.0.0"
o.default     = "0.0.0.0"
o.datatype    = "ipaddr"
o.rmempty     = false

o = s:option(Value, "chnlist_file", translate("CHNRoute File"))
o.placeholder = "/etc/chinadns-ng/chinalist.txt"
o.default     = "/etc/chinadns-ng/chinalist.txt"
o.datatype    = "file"
o.rmempty     = false

o = s:option(Value, "gfwlist_file", translate("GFWRoute File"))
o.placeholder = "/etc/chinadns-ng/gfwlist.txt"
o.default     = "/etc/chinadns-ng/gfwlist.txt"
o.datatype    = "file"
o.rmempty     = false

o = s:option(Value, "timeout_sec", translate("timeout_sec"))
o.placeholder = "3"
o.default     = "3"
o.datatype    = "uinteger"
o.rmempty     = false

o = s:option(Value, "repeat_times", translate("repeat_times"))
o.placeholder = "1"
o.default     = "1"
o.datatype    = "uinteger"
o.rmempty     = false

o = s:option(Value, "china_dns",
	translate("China DNS Servers"),
	translate("Use commas to separate multiple ip address, Max 2 Servers"))
o.placeholder = "114.114.114.114"
o.default     = "114.114.114.114"
o.rmempty     = false

o = s:option(Value, "trust_dns",
	translate("Trusted DNS Servers"),
	translate("Use commas to separate multiple ip address，Max 2 Servers"))
o.placeholder = "127.0.0.1#5300"
o.default     = "127.0.0.1#5300"
o.rmempty     = false

o = s:option(Flag, "chnlist_first",
	translate("match chnlist first"),
	translate("match chnlist first, default is gfwfirst"))
o.rmempty     = false

o = s:option(Flag, "reuse_port",
	translate("reuse_port"),
	translate("reuse_port，for Multi-process load balancing"))
o.rmempty     = false

o = s:option(Flag, "noip_as_chnip",
	translate("accept no ip"),
	translate("accept reply without ipaddr (A/AAAA query)"))
o.rmempty     = false

local apply=luci.http.formvalue("cbi.apply")
if apply then
	luci.sys.call("/etc/init.d/chinadns-ng restart >/dev/null 2>&1; logger -t 'luci-app-chinadns-ng' -p info 'chinadns-ng restarted.'")
end
return m
