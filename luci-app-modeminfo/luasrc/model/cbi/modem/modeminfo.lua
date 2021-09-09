-- Copyright 2021 Konstantine Shevlyakov <shevlakov@132lan.ru>
-- Copyright 2021 modified by Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0.

require("nixio.fs")

local TTY_PATH    = "/dev/tty[A-Z][A-Z]*"
local QMI_PATH    = "/dev/cdc-wdm*"

-- add device in ListValue
function addValues(dev, path)
    local try_port, size = nixio.fs.glob(path)
    dev:value("", translate("Autodetect"))
    if size > 0 then
        for node in try_port do
	    dev:value(node, node)
        end
        return false
    end
    return true
end

local m = Map("modeminfo", translate("Modeminfo: Configuration"),
	translate("Configuration panel of Мodeminfo."))

local s = m:section(TypedSection, "modeminfo")
s.anonymous = true

local name = s:option(Flag, "mmcli_name", translate("Named modem via mmcli"),
	translate("Get device model via mmcli utility if aviable."))
name:depends("qmi_mode", 0)
name.rmempty = true

local dev = s:option(ListValue, "device", translate("Modeminfo DATA port"),
	translate("In automatic mode detect first answered DATA port."))
dev.default = ""
dev.rmempty = true
dev:depends("qmi_mode", 0)
if addValues(dev, TTY_PATH) then
    -- message about missing TTY ports
    local o = s:option( DummyValue, "tty_nfound")
    o.rawhtml = true
    o:depends("qmi_mode", 0)
    function o.cfgvalue(self, section)
        return translate("<div style=\"color: red;\"><b>No port(s) found! Check the modem connection.</b></div>")
    end
end

dev = s:option(ListValue, "device_qmi", translate("Modeminfo DATA port"),
	translate("In automatic mode detect first answered DATA port."))
dev.default = ""
dev.rmempty = true
dev:depends("qmi_mode", 1)
if addValues(dev, QMI_PATH) then
    -- message about missing QMI ports
    local o = s:option( DummyValue, "qmi_nfound")
    o.rawhtml = true
    o:depends("qmi_mode", 1)
    function o.cfgvalue(self, section)
        return translate("<div style=\"color: red;\"><b>No port(s) found! Check the modem connection.</b></div>")
    end
end

local qmi_mode = s:option(Flag, "qmi_mode", translate("Use QMI"),
        translate("Get modem data via qmicli (experimental). qmi-utils will be installed."))
qmi_mode.rmempty = true

return m
