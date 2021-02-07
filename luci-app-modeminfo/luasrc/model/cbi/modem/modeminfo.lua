-- Copyright 2021 Konstantine Shevlyakov <shevlakov@132lan.ru>
-- Licensed to the GNU General Public License v3.0.

require("nixio.fs")

local m
local s
local dev
local try_port = nixio.fs.glob("/dev/ttyUSB*") or nixio.fs.glob("/dev/ttyACM*")

m = Map("modeminfo", translate("Modeminfo: Configuration"),
	translate("Configuration panel of Мodeminfo."))

s = m:section(TypedSection, "modeminfo")
s.anonymous = true

dev = s:option(ListValue, "device", translate("Modeminfo AT-port"),
	translate("In automatic mode detect first answered AT-port."))
if try_port then
	local node
	dev:value("", translate("Autodetect"))
	for node in try_port do
		dev:value(node, node)
	end
end
dev.default = ""
dev.rempty = true

return m
