-- Copyright 2008 Yanira <forum-2008@email.de>
-- Licensed to the public under the Apache License 2.0.

require("nixio.fs")

local m
local s
local dev, pin, lang
local try_devices = nixio.fs.glob("/dev/ttyUSB*") or nixio.fs.glob("/dev/ttyACM*") or nixio.fs.glob("/dev/cdc*")

m = Map("3ginfo", translate("Configuration 3ginfo"),
	translate("Configuration panel for the 3ginfo application."))

s = m:section(TypedSection, "3ginfo", "<p>&nbsp;</p>" .. translate(""))
s.anonymous = true

s:option(Value, "network", translate("Network"))
s.rmempty = true

dev = s:option(Value, "device", translate("Device"))
if try_devices then
local node
for node in try_devices do
dev:value(node, node)
end
end

pin = s:option(Value, "pincode", translate("SIM PIN (optional)"))
pin.default = ""

lang = s:option(Value, "language", translate("Language"))
lang:value("pl", "Polski")
lang:value("en", "English")
lang.default = "pl"

return m
