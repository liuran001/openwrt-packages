local m, s, o

m = Map("chinadns-ng", translate(""))

s = m:section(TypedSection, "chinadns-ng", translate("Rules Update"))
s.addremove = false
s.anonymous = true

o = s:option(Flag, "auto_update", translate("Auto Update"), translate("Auto update China ipset and route lists at 3:00 on Saturday"))
	o.rmempty     = false

o=s:option(DummyValue,"chinadns-ng_data",translate("Update Now"))
o.rawhtml  = true
o.template = "chinadns-ng/refresh"
o.value = " "

return m
