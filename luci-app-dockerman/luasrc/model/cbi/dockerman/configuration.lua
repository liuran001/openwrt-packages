-- Copyright 2021 Florian Eckert <fe@dev.tdt.de>
-- Licensed to the public under the Apache License 2.0.

local uci = require "luci.model.uci"

local m, s, o

m = Map("dockerd",
	translate("Docker - Configuration"),
	translate("DockerMan is a simple docker manager client for LuCI"))

s = m:section(NamedSection, "dockerman", "section", translate("Global settings"))
s:tab("daemon", translate("Docker Daemon"))
s:tab("ac", translate("Access Control"))
s:tab("dockerman", translate("DockerMan"))

o = s:taboption("dockerman", Flag, "remote_endpoint",
	translate("Remote Endpoint"),
	translate("Connect to remote docker endpoint"))
o.rmempty = false
o.enabled = "true"
o.disabled = "false"
o.validate = function(self, value, sid)
	local res = luci.http.formvaluetable("cbid.dockerd")
	if res["dockerman.remote_endpoint"] == "true" then
	 if res["dockerman.remote_port"] and res["dockerman.remote_port"] ~= "" and res["dockerman.remote_host"] and res["dockerman.remote_host"] ~= "" then
			return "true"
		else
			return nil, translate("Please input the PORT or HOST IP of remote docker instance!")
		end
	end
	return "false"
end

o = s:taboption("dockerman", Value, "socket_path",
	translate("Docker Socket Path"))
o.default = "/var/run/docker.sock"
o.placeholder = "/var/run/docker.sock"
o:depends("remote_endpoint", false)

o = s:taboption("dockerman", Value, "remote_host",
	translate("Remote Host"),
	translate("Host or IP Address for the connection to a remote docker instance"))
o.datatype = "host"
o.placeholder = "10.1.1.2"
o:depends("remote_endpoint", "true")

o = s:taboption("dockerman", Value, "remote_port",
	translate("Remote Port"))
o.placeholder = "2375"
o.datatype = "port"
o:depends("remote_endpoint", "true")

-- o = s:taboption("dockerman", Value, "status_path", translate("Action Status Tempfile Path"), translate("Where you want to save the docker status file"))
-- o = s:taboption("dockerman", Flag, "debug", translate("Enable Debug"), translate("For debug, It shows all docker API actions of luci-app-dockerman in Debug Tempfile Path"))
-- o.enabled="true"
-- o.disabled="false"
-- o = s:taboption("dockerman", Value, "debug_path", translate("Debug Tempfile Path"), translate("Where you want to save the debug tempfile"))

if nixio.fs.access("/usr/bin/dockerd") then
	o = s:taboption("ac", DynamicList, "ac_allowed_interface", translate("Allowed access interfaces"), translate("Which interface(s) can access containers under the bridge network, fill-in Interface Name"))
	local interfaces = luci.sys and luci.sys.net and luci.sys.net.devices() or {}
	for i, v in ipairs(interfaces) do
		o:value(v, v)
	end
	o = s:taboption("ac", DynamicList, "ac_allowed_container", translate("Containers allowed to be accessed"), translate("Which container(s) under bridge network can be accessed, even from interfaces that are not allowed, fill-in Container Id or Name"))
	-- allowed_container.placeholder = "container name_or_id"
	if containers_list then
		for i, v in ipairs(containers_list) do
			if	v.State == "running" and v.NetworkSettings and v.NetworkSettings.Networks and v.NetworkSettings.Networks.bridge and v.NetworkSettings.Networks.bridge.IPAddress then
				o:value(v.Id:sub(1,12), v.Names[1]:sub(2) .. " | " .. v.NetworkSettings.Networks.bridge.IPAddress)
			end
		end
	end

	o = s:taboption("daemon", Flag, "daemon_ea", translate("Enable"))
	o.enabled = "true"
	o.disabled = "false"
	o.rmempty = true

	o = s:taboption("daemon", Value, "daemon_data_root",
		translate("Docker Root Dir"))
	o.placeholder = "/opt/docker/"
	o:depends("remote_endpoint", 0)

	o = s:option(Value, "daemon_bip",
		translate("Default bridge"),
		translate("Configure the default bridge network"))
	o.placeholder = "172.17.0.1/16"
	o.datatype = "ipaddr"
	o:depends("remote_endpoint", 0)

	o = s:taboption("daemon", DynamicList, "daemon_registry_mirrors",
		translate("Registry Mirrors"),
		translate("It replaces the daemon registry mirrors with a new set of registry mirrors"))
	o.placeholder = translate("Example: https://hub-mirror.c.163.com")
	o:depends("remote_endpoint", 0)

	o = s:taboption("daemon", ListValue, "daemon_log_level",
		translate("Log Level"),
		translate('Set the logging level'))
	o:value("debug", translate("Debug"))
	o:value("", translate("Info")) -- This is the default debug level from the deamon is optin is not set
	o:value("warn", translate("Warning"))
	o:value("error", translate("Error"))
	o:value("fatal", translate("Fatal"))
	o.rmempty = true
	o:depends("remote_endpoint", 0)

	o = s:taboption("daemon", DynamicList, "daemon_hosts",
		translate("Client connection"),
		translate('Specifies where the Docker daemon will listen for client connections (default: unix:///var/run/docker.sock)'))
	o.placeholder = translate("Example: tcp://0.0.0.0:2375")
	o.rmempty = true
	o:depends("remote_endpoint", 0)
	
	local daemon_changes = 0
	m.on_before_save = function(self)
		local m_changes = m.uci:changes("dockerd")
		if not m_changes or not m_changes.dockerd or not m_changes.dockerd.dockerman then return end

		if m_changes.dockerd.dockerman.daemon_hosts then
			m.uci:set("dockerd", "globals", "hosts", m_changes.dockerd.dockerman.daemon_hosts)
			daemon_changes = 1
		end
		if m_changes.dockerd.dockerman.daemon_bip then
			m.uci:set("dockerd", "globals", "bip", m_changes.dockerd.dockerman.daemon_bip)
			daemon_changes = 1
		end
		if m_changes.dockerd.dockerman.daemon_registry_mirrors then
			m.uci:set("dockerd", "globals", "registry_mirrors", m_changes.dockerd.dockerman.daemon_registry_mirrors)
			daemon_changes = 1
		end
		if m_changes.dockerd.dockerman.daemon_data_root then
			m.uci:set("dockerd", "globals", "data_root", m_changes.dockerd.dockerman.daemon_data_root)
			daemon_changes = 1
		end
		if m_changes.dockerd.dockerman.daemon_log_level then
			luci.model.uci.cursor():set("dockerd", "globals", "log_level", m_changes.dockerd.dockerman.daemon_log_level)
			daemon_changes = 1
		end
		if m_changes.dockerd.dockerman.daemon_ea then
			if m_changes.dockerd.dockerman.daemon_ea == "false" then
				daemon_changes = -1
			elseif daemon_changes == 0 then
				daemon_changes = 1
			end
		end
	end

	m.on_after_commit = function(self)
		if daemon_changes == 1 then
			luci.util.exec("/etc/init.d/dockerd enable")
			luci.util.exec("/etc/init.d/dockerd restart")
		elseif daemon_changes == -1 then
			luci.util.exec("/etc/init.d/dockerd stop")
			luci.util.exec("/etc/init.d/dockerd disable")
		end
		luci.util.exec("/etc/init.d/dockerman start")
	end
end

return m
