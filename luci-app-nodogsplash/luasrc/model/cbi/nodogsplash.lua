local net = require "luci.model.network".init()
local sys = require "luci.sys"
local nt = require "luci.sys".net
local ifaces = sys.net:devices()

m = Map ("nodogsplash", translate ("WiFi portal"), translate ("Please close the transparent proxy of the client network (such as advertisement filtering and ssr), otherwise it will cause conflict and cause the client network to be unable to access the Internet."))

m:section(SimpleSection).template  = "nodogsplash/nodogsplash_status"

s = m:section(TypedSection, "nodogsplash", "")
s:tab("tab_basic", translate("Base Setting"))
s:tab("advanced", translate("Advance Setting"))
s.addremove = false
s.anonymous = true

--Base Setting
e = s:taboption("tab_basic", Flag, "enabled", translate("enable"))


n = s:taboption("tab_basic", ListValue, "gatewayinterface", translate("Interface name"))

for _, iface in ipairs(ifaces) do
	if not (iface == "lo" or iface:match("^ifb.*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		n:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end

gatewayname= s:taboption("tab_basic", Value, "gatewayname", "认证页名称")
gatewayname.optional = true
gatewayname.description = translate("Name displayed on portal page.")

PreAuthIdleTimeout= s:taboption("tab_basic", Value, "preauthidletimeout", translate("Equipment Disconnection Retention Authentication (sub)"))
PreAuthIdleTimeout.placeholder = "30"
PreAuthIdleTimeout.datatype="integer"

AuthIdleTimeout= s:taboption("tab_basic", Value, "authidletimeout", translate("Time of equipment re-certification (minutes)"))
AuthIdleTimeout.placeholder = "120"
AuthIdleTimeout.datatype="integer"

sessiontimeout= s:taboption("tab_basic", Value, "sessiontimeout", translate("Portal page timeout (seconds)"))
sessiontimeout.placeholder = "1200"
sessiontimeout.datatype="integer"

checkinterval= s:taboption("tab_basic", Value, "checkinterval", translate("Check the authentication status interval (seconds)"))
checkinterval.placeholder = "600"
checkinterval.datatype="integer"

--Advance Setting

fwhook = s:taboption("advanced", Flag, "fwhook_enabled", translate("nodogsplash restart when the firewall restarts."))
fwhook.description = translate("Open by default")

gatewayport= s:taboption("advanced", Value, "gatewayport", "使用的端口号")
gatewayport.optional = true
gatewayport.placeholder = "2050"
gatewayport.datatype="integer"

web = s:taboption("advanced", Value, "webroot", translate("WEB folder"))
web.placeholder = "/etc/nodogsplash/htdocs"

maxclients= s:taboption("advanced", Value, "maxclients", "最大用户数量")
maxclients.placeholder = "250"
maxclients.datatype="integer"

debuglevel= s:taboption("advanced", Value, "debuglevel", "日志调试级别 0-7")
debuglevel.optional = true
debuglevel.rmempty = false 
debuglevel.placeholder = "7"
debuglevel.datatype="integer"

o=s:taboption("advanced", ListValue,"temp_type",translate("Choose a validation method"))
o:value("",translate("Default"))
o:value("binauth",translate("Shell Verification"))
o:value("fasport",translate("Enable Forwarding Authentication Service (FAS)"))
o:value("preauth",translate("Enable username/emailaddress login."))
o.rmempty = false 
o.optional = true

binauth= s:taboption("advanced", Value, "binauth", "Shell 脚本路径")
binauth.placeholder = "/bin/myauth.sh"
binauth.rmempty = false 
binauth.optional = true
binauth.description = translate("The shell script will be invoked for authentication. <br/> If you need to use it, please refer to Wiki to create scripts")
binauth:depends({temp_type="binauth"})

fasport= s:taboption("advanced", Value, "fasport", "使用的端口号")
fasport.rmempty = false 
fasport.optional = true
fasport.description = translate("if FAS is running locally (ie fasremoteip is NOT set), port 80 cannot be used.<br/>Typical Remote Shared Hosting Example:80.Typical Locally Hosted example (ie fasremoteip not set):2080.<br/>if Enable username/emailaddress login.fasport must be set to the same value as gatewayport (default = 2050)")
fasport:depends({temp_type="fasport"})

fasremoteip = s:taboption("advanced", Value, "fasremoteip ", "验证服务器 ip 地址")
fasremoteip .rmempty = false 
fasremoteip .optional = true
fasremoteip :depends({temp_type="fasport"})

faspath= s:taboption("advanced", Value, "faspath", "验证页面地址")
faspath.rmempty = false 
faspath.optional = true
faspath.description = translate("The path of login page under Web root directory,<br/>'/nodog/fas.php'<br/>If it is a user name login authentication method.<br/>'/nodogsplash_preauth/'")
faspath:depends({temp_type="fasport"})

mailport= s:taboption("advanced", Value, "fasport", "使用的端口号")
mailport.placeholder = "2050"
mailport.rmempty = false 
mailport.optional = true
mailport:depends({temp_type="preauth"})

mailpath= s:taboption("advanced", Value, "faspath", "faspath")
mailpath.placeholder = "/nodogsplash_preauth/"
mailpath.rmempty = false
mailpath.optional = true
mailpath:depends({temp_type="preauth"})

mailpreauth= s:taboption("advanced", Value, "preauth", "验证脚本路径")
mailpreauth.placeholder = "/usr/lib/nodogsplash/login.sh"
mailpreauth.rmempty = false 
mailpreauth.optional = true
mailpreauth.description = translate("The shell script will be invoked for authentication. <br/> If you need to use it, please refer to Wiki to create scripts")
mailpreauth:depends({temp_type="preauth"})

fas_secure_enabled= s:taboption("advanced", Value, "fas_secure_enabled", "客户端 tok 令牌加密（0-1）")
fas_secure_enabled.rmempty = false 
fas_secure_enabled.optional = true
fas_secure_enabled.placeholder = "1"
fas_secure_enabled.datatype="integer"
fas_secure_enabled.description = translate("If set to ‘0’, the client token is sent to the FAS in clear text in the query string of the.")

preauthenticated_users = s:taboption("advanced", DynamicList, "preauthenticated_users", translate("Open Port Before Authentication"))
preauthenticated_users.rmempty = false 
preauthenticated_users.optional = true
preauthenticated_users.description = translate("<br/>allow：<br/>allow tcp port 80<br/>allow udp port 53")

users_to_router = s:taboption("advanced", DynamicList, "users_to_router", translate("LAN Open Port"))
users_to_router.rmempty = false 
users_to_router.optional = true
users_to_router.description = translate("<br/>allow：<br/>allow tcp port 80<br/>allow udp port 53")

authenticated_users = s:taboption("advanced", DynamicList, "authenticated_users", translate("Authenticated client isolation settings"))
	--luci.sys.net.ipv4_hints(function(ip, name)
	--	authenticated_users:value(ip, "%s (%s)" %{ ip, name })
	--end)
authenticated_users.rmempty = false 
authenticated_users.optional = true
authenticated_users.description = translate("<br/>allow：<br/>allow tcp port 80<br/>allow udp port 53<br/>allow all<br/>block：<br/>block to 192.168.0.0/16<br/>192.168.X.1 80 Port Isolation Invalid.")

mac=s:taboption("advanced", ListValue,"macmechanism",translate("MAC Filter"))
mac:value("",translate("disable"))
mac:value("allow",translate("Only allowed in the list"))
mac:value("block",translate("Allow only out of the list"))

allowedmac = s:taboption("advanced", DynamicList, "allowedmac", translate("Bypass MAC List"))
nt.mac_hints(function(mac, name) allowedmac :value(mac, "%s (%s)" %{ mac, name }) end)
allowedmac.rmempty = false 
allowedmac.optional = true
allowedmac:depends({macmechanism="allow"})

blockedmac = s:taboption("advanced", DynamicList, "blockedmac", translate("Black MAC List"))
nt.mac_hints(function(mac, name) blockedmac:value(mac, "%s (%s)" %{ mac, name }) end)
blockedmac.rmempty = false 
blockedmac.optional = true
blockedmac:depends({macmechanism="block"})

trustedmac= s:taboption("advanced", DynamicList, "trustedmac", translate("Trusted MAC List"))
nt.mac_hints(function(mac, name) trustedmac:value(mac, "%s (%s)" %{ mac, name }) end)
trustedmac.rmempty = false 
trustedmac.optional = true

temp_mask = s:taboption("advanced", Flag, "temp_mask", translate("uses specific HEXADECIMAL values to mark packets used by iptables as a bitwise mask."))
temp_mask.description = translate("<br/> Modify the packet marker hexadecimal mask <br/> without modification if necessary. < br /> if you need visitor equipment to support adbyby, ssr.... See the default package tag. Modify iptables by yourself. <br/>")
fw_mark_authenticated= s:taboption("advanced", DynamicList, "fw_mark_authenticated", translate("fw_mark_authenticated"))
fw_mark_authenticated:depends("temp_mask", "1")
fw_mark_authenticated.placeholder = "30000"
fw_mark_trusted= s:taboption("advanced", DynamicList, "fw_mark_trusted", translate("fw_mark_trusted"))
fw_mark_trusted:depends("temp_mask", "1")
fw_mark_trusted.placeholder = "20000"
fw_mark_blocked= s:taboption("advanced", DynamicList, "fw_mark_blocked", translate("fw_mark_blocked"))
fw_mark_blocked:depends("temp_mask", "1")
fw_mark_blocked.placeholder = "10000"
	


local apply = luci.http.formvalue("cbi.apply")
 if apply then
     io.popen("sed -i '/temp_type/'d /etc/config/nodogsplash")
     io.popen("sed -i '/temp_mask/'d /etc/config/nodogsplash")
     io.popen("/etc/init.d/nodogsplash start")
end
return m

