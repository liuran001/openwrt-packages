-- Copyright 2021 Konstantine Shevlyakov <shevlakov@132lan.ru>
-- Licensed to the GNU General Public License v3.0.

require("nixio.fs")
local uci = require "luci.model.uci"
local m
local s
local dev
try_port = nixio.fs.glob("/dev/tty[A-Z][A-Z]*")

m = Map("modeminfo", translate("Modeminfo: Configuration"),
	translate("Configuration panel of Мodeminfo."))

s = m:section(TypedSection, "modeminfo")
s.anonymous = true

name = s:option(Flag, "mmcli_name", translate("Named modem via mmcli"),
	translate("Get device model via mmcli utility if aviable."))
name:depends("qmi_mode", 0)
name.rmempty = true

dev = s:option(ListValue, "device", translate("Modeminfo DATA port"),
	translate("In automatic mode detect first answered DATA port."))

if uci.cursor():get_first("modeminfo", "modeminfo", "qmi_mode") then
	try_port = nixio.fs.glob("/dev/cdc-wdm*")
end

if try_port then
	local node
	dev:value("", translate("Autodetect"))
	for node in try_port do
		dev:value(node, node)
	end
end

dev.default = ""
dev.rempty = true

qmi_mode = s:option(Flag, "qmi_mode", translate("Use QMI"),
        translate("Get modem data via qmicli (experimental). qmi-utils will be installed."))
qmi_mode.rmempty = true


return m
