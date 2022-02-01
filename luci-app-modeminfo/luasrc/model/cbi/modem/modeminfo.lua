-- Copyright 2021 Konstantine Shevlyakov <shevlakov@132lan.ru>
-- Copyright 2021 modified by Vladislav Kadulin <spanky@yandex.ru>
-- Licensed to the GNU General Public License v3.0.

require("nixio.fs")

local PATH = {
	"/dev/tty[A-Z][A-Z]*",
	"/dev/cdc-wdm*"
	}

-- check devices
function check_dev(path)
    local try_port, size = nixio.fs.glob(path)
    if size > 0 then
        port = translate("In automatic mode detect first answered DATA port.")
    else
	port = translate("Port not found!")
    end
end

-- add device in ListValue
function try_port(path)
   local try_port = nixio.fs.glob(path)
   dev:value("", translate("Autodetect"))
   for node in try_port do
      dev:value(node, node)
   end
end

local m = Map("modeminfo", translate("Modeminfo: Configuration"),
	translate("Configuration panel of Modeminfo."))

local s = m:section(TypedSection, "modeminfo")
s.anonymous = true

local qmi_mode = s:option(Flag, "qmi_mode", translate("Use QMI"),
        translate("Get modem data via qmicli (experimental). Require install qmi-utils."))
qmi_mode.rmempty = true

check_dev(PATH[1])
dev = s:option(ListValue, "device", translate("Data port"), port)
dev.default = ""
dev.rmempty = true
dev:depends("qmi_mode", 0)
try_port(PATH[1])

check_dev(PATH[2])
dev = s:option(ListValue, "device_qmi", translate("Data port"), port)
dev.default = ""
dev.rmempty = true
dev:depends("qmi_mode", 1)
try_port(PATH[2])

local decimail = s:option(Flag, "decimail", translate("Show decimal"),
	translate("Show LAC and CID in decimal."))
decimail.rmempty = true

local name = s:option(Flag, "mmcli_name", translate("Name via mmcli"),
        translate("Get device hardware name via mmcli utility if aviable."))
name.rmempty = true
name:depends("qmi_mode", 0)

local qmi_proxy = s:option(Flag, "qmi_proxy", translate("QMI proxy"),
        translate("Enable qmi-proxy mode."))
qmi_proxy.rmempty = true
qmi_proxy:depends("qmi_mode", 1)

function m.on_after_commit(Map)
        luci.sys.call("rm -f /tmp/modemdevice")
end

return m
