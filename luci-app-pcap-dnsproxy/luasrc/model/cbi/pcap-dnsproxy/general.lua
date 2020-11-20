-- Copyright 2017-2018 Dirk Brenken (dev@brenken.org)
-- Copyright 2015 Matthew <https://github.com/matthew728960>
-- Copyright 2020 muink <https://github.com/muink>
-- Licensed to the public under the Apache License 2.0

local uci	= require "luci.model.uci".cursor()
local fs	= require("nixio.fs")
local sys	= require("luci.sys")
local util	= require("luci.util")
local packageName = "pcap-dnsproxy"
local conf = packageName
local config = "/etc/config/" .. conf

local packageVersion = tostring(util.trim(sys.exec("opkg list-installed " .. packageName .. " | awk '{print $3}'"))) or nil
local packageStatus, packageStatusCode
local ubusStatus = util.ubus("service", "list", { name = packageName })

if not packageVersion then
	packageStatusCode = -1
	packageStatus = translatef("%s is not installed or not found", packageName)
else  
	if not ubusStatus or not ubusStatus[packageName] then
		packageStatusCode = 0
		packageStatus = translate("Stopped")
		if not sys.init.enabled(packageName) then
			packageStatus = packageStatus .. " (" .. translate("disabled") .. ")"
		end
	else
		packageStatusCode, packageStatus = 1, translate("Running")
		local StatusPort = tostring(util.trim(sys.exec("echo `netstat -lpntu | grep Pcap_DNSProxy | grep \"^udp\" | sed -En \"s|^.\*\\b([0-9]+\\\.[0-9]+\\\.[0-9]+\\\.[0-9]+):([0-9]+)\\b.\*\$|\\2|p\" | sort -nu` | sed 's/ /, /g'")))
		if StatusPort and not (StatusPort == "") then
			packageStatus = packageStatus .. " - " .. translatef("Port: %s", StatusPort)
		end
	end
end


m = Map(conf, "")


h = m:section(TypedSection, "pcap-dnsproxy", translatef("Service Status [%s %s]", packageName, packageVersion or translate("null")))
h.anonymous = true

ss = h:option(DummyValue, "_dummy", translate("Service Status"))
ss.template = packageName .. "/status"
ss.value = packageStatus

if not (packageStatusCode == -1) then
	buttons = h:option(DummyValue, "_dummy")
	buttons.template = packageName .. "/buttons"
end


if sys.call("netstat -lpntu | grep Pcap_DNSProxy") == 0 then
	take_over = h:option(Button, "_button0", translate("Take over system DNS request to pcap-dnsproxy"))
	take_over.inputtitle = translate("Take over DNS")
else
	take_over = h:option(Button, "_button0", translate("Restore system DNS"))
	take_over.inputtitle = translate("Restore DNS")
end
take_over.inputstyle = "apply"
function take_over.write (self, section)
	sys.call ( "uci del dhcp.@dnsmasq[0].server")
	sys.call ( "for v in \$(echo `netstat -lpntu | grep Pcap_DNSProxy | grep \"^udp\" | sed -En \"s|^.\*\\b([0-9]+\\\.[0-9]+\\\.[0-9]+\\\.[0-9]+):([0-9]+)\\b.\*\$|\\2|p\" | sort -nu`); do uci add_list dhcp.@dnsmasq[0].server=\"::1#\$v\"; uci add_list dhcp.@dnsmasq[0].server=\"127.0.0.1#\$v\"; done")
	sys.call ( "uci commit dhcp")
	sys.call ( "/etc/init.d/dnsmasq restart")
end

app_sys = h:option(Button, "_button1", translate("Apply to System"))
app_sys.inputtitle = translate("Apply to System")
app_sys.inputstyle = "apply"
function app_sys.write (self, section)
	sys.call ( "/usr/bin/pcap-dnsproxy.sh uci2conf_full")
end

load_sys = h:option(Button, "_button2", translate("Load from System"),
	translate("You may need to revert&apply 'UNSAVED CHANGES' once"))
load_sys.inputtitle = translate("Load from System")
load_sys.inputstyle = "apply"
function load_sys.write (self, section)
	sys.call ( "/usr/bin/pcap-dnsproxy.sh conf2uci_full")
end

resetall = h:option(Button, "_button3", translate("Reset All settings"),
	translate("You may need to revert&apply 'UNSAVED CHANGES' once"))
resetall.inputtitle = translate("Reset All settings")
resetall.inputstyle = "apply"
function resetall.write (self, section)
	sys.call ( "/usr/bin/pcap-dnsproxy.sh reset_full")
end


s = m:section(TypedSection, "main", translate("General Settings"),
	translatef("For further information "
		.. "<a href=\"%s\" target=\"_blank\">"
		.. "check the online documentation</a>", translate("https://github.com/wongsyrone/Pcap_DNSProxy/blob/master/Documents/ReadMe.en.txt")))
s.anonymous = true


--[[ Tab section ]]--

s:tab("general", translate("General Settings"))
s:tab("ll_dns", translate("Local DNS Request"))
s:tab("parameter", translate("Parameter"))
s:tab("adv_set", translate("Advanced"))
s:tab("proxy_set", translate("DNS Proxy"))
s:tab("dnscurve_set", translate("DNSCurve"))


--[[ General Settings ]]--

listen_proto = s:taboption("general", ListValue, "listen_proto", translate("Listen Protocol"))
listen_proto:value("IPv4 + UDP")
listen_proto:value("IPv4 + TCP")
listen_proto:value("IPv4 + TCP + UDP")
listen_proto:value("IPv6 + UDP")
listen_proto:value("IPv6 + TCP")
listen_proto:value("IPv6 + TCP + UDP")
listen_proto:value("IPv6 + IPv4 + UDP")
listen_proto:value("IPv6 + IPv4 + TCP")
listen_proto:value("IPv6 + IPv4 + TCP + UDP")

listen_port = s:taboption("general", Value, "listen_port", translate("Listen Port"))
listen_port.placeholder = "1053(|2053)"

operation_mode = s:taboption("general", ListValue, "operation_mode", translate("Operation Mode"))
operation_mode:value("Server", translate("Server mode"))
operation_mode:value("Private", translate("Private network mode"))
operation_mode:value("Proxy", translate("Proxy mode"))
operation_mode:value("Custom", translate("Custom mode"))

ipv4_listen_addr = s:taboption("general", Value, "ipv4_listen_addr", translate("IPv4 Listen Address"))
ipv4_listen_addr.placeholder = "192.168.1.1:53|192.168.10.1:53"
ipv4_listen_addr.rmempty = true
ipv4_listen_addr:depends("operation_mode", "Custom")

ipv6_listen_addr = s:taboption("general", Value, "ipv6_listen_addr", translate("IPv6 Listen Address"))
ipv6_listen_addr.placeholder = "[fd1e:b741:ea46::e28]:53|[240e:e0:865:ed0:1c6e:e5ff:fed0:631e]:53"
ipv6_listen_addr.rmempty = true
ipv6_listen_addr:depends("operation_mode", "Custom")

--== DNS Request ==--

global_proto = s:taboption("general", ListValue, "global_proto", translate("Outgoing Protocol"))
global_proto:value("IPv4 + UDP")
global_proto:value("IPv4 + Force TCP")
global_proto:value("IPv4 + TCP + UDP")
global_proto:value("IPv6 + UDP")
global_proto:value("IPv6 + Force TCP")
global_proto:value("IPv6 + TCP + UDP")
global_proto:value("IPv4 + IPv6 + UDP")
global_proto:value("IPv4 + IPv6 + Force TCP")
global_proto:value("IPv4 + IPv6 + TCP + UDP")

global_ipv4_addr = s:taboption("general", Value, "global_ipv4_addr", translate("IPv4 Main DNS Address"))
global_ipv4_addr.placeholder = "8.8.4.4:53"
global_ipv4_addr.rmempty = false

global_ipv4_ttl = s:taboption("general", Value, "global_ipv4_ttl", translate("IPv4 Main DNS TTL"))
global_ipv4_ttl.placeholder = "TTL(8.8.4.4)"

global_ipv4_addr_alt = s:taboption("general", Value, "global_ipv4_addr_alt", translate("IPv4 Alternate DNS Address"))
global_ipv4_addr_alt.placeholder = "1.0.0.1:53|149.112.112.112:53|208.67.220.220:5353"
global_ipv4_addr_alt.rmempty = false

global_ipv4_ttl_alt = s:taboption("general", Value, "global_ipv4_ttl_alt", translate("IPv4 Alternate DNS TTL"))
global_ipv4_ttl_alt.placeholder = "TTL(1.0.0.1)|TTL(149.112.112.112)|TTL(208.67.220.220)"

global_ipv6_addr = s:taboption("general", Value, "global_ipv6_addr", translate("IPv6 Main DNS Address"))
global_ipv6_addr.placeholder = "[2001:4860:4860::8844]:53"
global_ipv6_addr.rmempty = false

global_ipv6_ttl = s:taboption("general", Value, "global_ipv6_ttl", translate("IPv6 Main DNS Hop Limits"))
global_ipv6_ttl.placeholder = "Hop-Limit(2001:4860:4860::8844)"

global_ipv6_addr_alt = s:taboption("general", Value, "global_ipv6_addr_alt", translate("IPv6 Alternate DNS Address"))
global_ipv6_addr_alt.placeholder = "[2606:4700:4700::1001]:53|[2620:FE::9]:53|[2620:0:CCD::2]:5353"
global_ipv6_addr_alt.rmempty = false

global_ipv6_ttl_alt = s:taboption("general", Value, "global_ipv6_ttl_alt", translate("IPv6 Alternate DNS Hop Limits"))
global_ipv6_ttl_alt.placeholder = "Hop-Limit(2606:4700:4700::1001)|Hop-Limit(2620:FE::9)|Hop-Limit(2620:0:CCD::2)"

edns_client_subnet_ipv4_addr = s:taboption("general", Value, "edns_client_subnet_ipv4_addr", translate("IPv4 EDNS Client Subnet Address"),
	translate("EDNS Client Subnet Relay parameter priority is higher than this parameter.")
	.. "<br/>"
	.. translate("After enabling, the EDNS subnet address of EDNS Client Subnet Relay will be added preferentially."))
edns_client_subnet_ipv4_addr.datatype = "cidr4"
edns_client_subnet_ipv4_addr.placeholder = "202.97.82.0/24"
edns_client_subnet_ipv4_addr.rmempty = true
edns_client_subnet_ipv4_addr:depends("edns_label", "1")
edns_client_subnet_ipv4_addr:depends("edns_label", "2")

edns_client_subnet_ipv6_addr = s:taboption("general", Value, "edns_client_subnet_ipv6_addr", translate("IPv6 EDNS Client Subnet Address"),
	translate("EDNS Client Subnet Relay parameter priority is higher than this parameter.")
	.. "<br/>"
	.. translate("After enabling, the EDNS subnet address of EDNS Client Subnet Relay will be added preferentially."))
edns_client_subnet_ipv6_addr.datatype = "cidr6"
edns_client_subnet_ipv6_addr.placeholder = "240e:e0:865:ed0::/56"
edns_client_subnet_ipv6_addr.rmempty = true
edns_client_subnet_ipv6_addr:depends("edns_label", "1")
edns_client_subnet_ipv6_addr:depends("edns_label", "2")


--[[ Local DNS Request ]]--

ll_proto = s:taboption("ll_dns", ListValue, "ll_proto", translate("Local Protocol"))
ll_proto:value("IPv4 + UDP")
ll_proto:value("IPv4 + Force TCP")
ll_proto:value("IPv4 + TCP + UDP")
ll_proto:value("IPv6 + UDP")
ll_proto:value("IPv6 + Force TCP")
ll_proto:value("IPv6 + TCP + UDP")
ll_proto:value("IPv4 + IPv6 + UDP")
ll_proto:value("IPv4 + IPv6 + Force TCP")
ll_proto:value("IPv4 + IPv6 + TCP + UDP")
--ll_proto.rmempty = false
ll_proto:depends("ll_filter_mode", "hostlist")
ll_proto:depends("ll_filter_mode", "routing")

ll_filter_mode = s:taboption("ll_dns", ListValue, "ll_filter_mode", translate("Filter Mode"))
ll_filter_mode:value("0", translate("Disable"))
ll_filter_mode:value("hostlist", translate("Local Hosts"))
ll_filter_mode:value("routing", translate("Local Routing"))
ll_filter_mode.rmempty = false

ll_force_req = s:taboption("ll_dns", Flag, "ll_force_req", translate("Local Force Request"))
ll_force_req.rmempty = true
ll_force_req:depends("ll_filter_mode", "hostlist")

ll_ipv4_addr = s:taboption("ll_dns", Value, "ll_ipv4_addr", translate("IPv4 Local Main DNS Address"))
ll_ipv4_addr.placeholder = "114.114.115.115:53"
--ll_ipv4_addr.rmempty = false
ll_ipv4_addr:depends("ll_filter_mode", "hostlist")
ll_ipv4_addr:depends("ll_filter_mode", "routing")

ll_ipv4_addr_alt = s:taboption("ll_dns", Value, "ll_ipv4_addr_alt", translate("IPv4 Local Alternate DNS Address"))
ll_ipv4_addr_alt.placeholder = "223.6.6.6:53"
--ll_ipv4_addr_alt.rmempty = false
ll_ipv4_addr_alt:depends("ll_filter_mode", "hostlist")
ll_ipv4_addr_alt:depends("ll_filter_mode", "routing")

ll_ipv6_addr = s:taboption("ll_dns", Value, "ll_ipv6_addr", translate("IPv6 Local Main DNS Address"))
ll_ipv6_addr.placeholder = "[240C::6644]:53"
--ll_ipv6_addr.rmempty = false
ll_ipv6_addr:depends("ll_filter_mode", "hostlist")
ll_ipv6_addr:depends("ll_filter_mode", "routing")

ll_ipv6_addr_alt = s:taboption("ll_dns", Value, "ll_ipv6_addr_alt", translate("IPv6 Local Alternate DNS Address"))
ll_ipv6_addr_alt.placeholder = "[240C::6666]:53"
--ll_ipv6_addr_alt.rmempty = false
ll_ipv6_addr_alt:depends("ll_filter_mode", "hostlist")
ll_ipv6_addr_alt:depends("ll_filter_mode", "routing")


--[[ Parameter ]]--

mult_req_time = s:taboption("parameter", Value, "mult_req_time", translate("Multiple requests"),
	translate("Send parallel requests to the same remote server at a time")
	.. "<br/>"
	.. translate("Unless the packet loss is very high, not recommended to open"))
mult_req_time.datatype = "or(range(0,0),range(2,32))"
mult_req_time:value("", translate("Use Default"))
mult_req_time:value("0", translate("0 - Disable - Once"))
mult_req_time:value("2", translate("2 - Double"))
mult_req_time:value("3", translate("3 - Triple"))

cc_type = s:taboption("parameter", ListValue, "cc_type", translate("DNS Cache Type"))
cc_type:value("0", translate("Disable"))
cc_type:value("Timer", translate("Timer"))
cc_type:value("Queue", translate("Queue"))
cc_type:value("Timer + Queue", translate("Timer + Queue"))

cc_parameter = s:taboption("parameter", Value, "cc_parameter", translate("DNS Cache Parameter"))
cc_parameter.datatype = "ufloat"
cc_parameter.placeholder = "4096"
cc_parameter.rmempty = false

cc_default_ttl = s:taboption("parameter", Value, "cc_default_ttl", translate("DNS Cache Default TTL"),
	translate("In seconds"))
cc_default_ttl.datatype = "ufloat"
cc_default_ttl.placeholder = "900"
--cc_default_ttl.rmempty = false
cc_default_ttl:depends("cc_type", "Timer + Queue")

--------

ipv4_packet_ttl = s:taboption("parameter", Value, "ipv4_packet_ttl", translate("IPv4 Packet TTL"),
	translate("0 is automatically determined by the operating system, the value of 1 - 255 between"))
ipv4_packet_ttl.placeholder = "72 - 255"
ipv4_packet_ttl.rmempty = false

ipv6_packet_ttl = s:taboption("parameter", Value, "ipv6_packet_ttl", translate("IPv6 Packet Hop Limits"),
	translate("0 is automatically determined by the operating system, the value of 1 - 255 between"))
ipv6_packet_ttl.placeholder = "72 - 255"
ipv6_packet_ttl.rmempty = false

ttl_tolerance = s:taboption("parameter", Value, "ttl_tolerance", translate("IPv4 TTL/IPv6 Hop Limits Tolerance"),
	translate("IPv4 TTL/IPv6 Hop Limits value range of ± data packets can be accepted, to avoid the short-term changes in the network environment caused by the failure of the problem"))
ttl_tolerance.datatype = "range(0,255)"
ttl_tolerance.placeholder = "1"
ttl_tolerance.rmempty = false

reliable_once_socket_timeout = s:taboption("parameter", Value, "reliable_once_socket_timeout", translate("Reliable Once Socket Timeout"),
	translate("In milliseconds, with a minimum of 500")
--	.. "<br/>"
--	.. translate("One-time refers to the request in a RTT round-trip network transmission can be completed, such as standard DNS and DNSCurve (DNSCrypt) agreement")
--	.. "<br/>"
--	.. translate("Reliable port refers to TCP protocol")
	)
reliable_once_socket_timeout.datatype = "or(range(0,0),range(500,2147483647))"
reliable_once_socket_timeout.placeholder = "3000"

reliable_serial_socket_timeout = s:taboption("parameter", Value, "reliable_serial_socket_timeout", translate("Reliable Serial Socket Timeout"),
	translate("In milliseconds, with a minimum of 500")
--	.. "<br/>"
--	.. translate("Tandem means that this operation requires multiple interactive network transmission to complete, such as SOCKS and HTTP CONNECT agreement")
--	.. "<br/>"
--	.. translate("Reliable port refers to TCP protocol")
	)
reliable_serial_socket_timeout.datatype = "or(range(0,0),range(500,2147483647))"
reliable_serial_socket_timeout.placeholder = "1500"

unreliable_once_socket_timeout = s:taboption("parameter", Value, "unreliable_once_socket_timeout", translate("Unreliable Once Socket Timeout"),
	translate("In milliseconds, with a minimum of 500")
--	.. "<br/>"
--	.. translate("One-time refers to the request in a RTT round-trip network transmission can be completed, such as standard DNS and DNSCurve (DNSCrypt) agreement")
--	.. "<br/>"
--	.. translate("Unreliable port refers to UDP/ICMP/ICMPv6 agreement")
	)
unreliable_once_socket_timeout.datatype = "or(range(0,0),range(500,2147483647))"
unreliable_once_socket_timeout.placeholder = "2000"

unreliable_serial_socket_timeout = s:taboption("parameter", Value, "unreliable_serial_socket_timeout", translate("Unreliable Serial Socket Timeout"),
	translate("In milliseconds, with a minimum of 500")
--	.. "<br/>"
--	.. translate("Tandem means that this operation requires multiple interactive network transmission to complete, such as SOCKS and HTTP CONNECT agreement")
--	.. "<br/>"
--	.. translate("Unreliable port refers to UDP/ICMP/ICMPv6 agreement")
	)
unreliable_serial_socket_timeout.datatype = "or(range(0,0),range(500,2147483647))"
unreliable_serial_socket_timeout.placeholder = "1000"

--------

icmp_test = s:taboption("parameter", Value, "icmp_test", translate("ICMP Test"),
	translate("In seconds"))
icmp_test.datatype = "or(range(0,0),range(5,2147483647))"
icmp_test:value("", translate("Use Default"))
icmp_test:value("0", translate("0 - Disable"))
icmp_test:value("900")
--icmp_test.default = "0"

domain_test = s:taboption("parameter", Value, "domain_test", translate("Domain Test"),
	translate("In seconds"))
domain_test.datatype = "or(range(0,0),range(5,2147483647))"
domain_test:value("", translate("Use Default"))
domain_test:value("0", translate("0 - Disable"))
domain_test:value("900")
--domain_test.default = "0"

--------

alt_times = s:taboption("parameter", Value, "alt_times", translate("Alternate Server Failure Thresholds"))
alt_times.datatype = "min(1)"
alt_times.placeholder = "10"

alt_times_range = s:taboption("parameter", Value, "alt_times_range", translate("Alternate Server Failed Thresholds Calculation Period"),
	translate("In seconds, with a minimum of 5"))
alt_times_range.datatype = "min(5)"
alt_times_range.placeholder = "60"

alt_reset_time = s:taboption("parameter", Value, "alt_reset_time", translate("Alternate Server Reset Time"),
	translate("In seconds, with a minimum of 5"))
alt_reset_time.datatype = "min(5)"
alt_reset_time.placeholder = "300"


--[[ Advanced ]]--

server_domain = s:taboption("adv_set", Value, "server_domain", translate("Pcap_DNSProxy Server Name"))
server_domain.placeholder = "pcap-dnsproxy.local"

pcap_capt = s:taboption("adv_set", Flag, "pcap_capt", translate("Pcap Capture"),
	translate("If disabled, it will automatically open the 'Direct Request' feature"))

pcap_devices_blklist = s:taboption("adv_set", Value, "pcap_devices_blklist", translate("Pcap Devices Blacklist"),
	translate("Format: AnyConnect|Host|Hyper|ISATAP|IKE|L2TP|Only|Oracle|PPTP|Pseudo|Teredo|Tunnel|Virtual|VMNet|VMware|VPN|any|gif|ifb|lo|nflog|nfqueue|stf|tunl|utun"))
pcap_devices_blklist.placeholder = "AnyConnect|Host|Hyper|ISATAP|IKE|L2TP|Only|Oracle|PPTP|Pseudo|Teredo|Tunnel|Virtual|VMNet|VMware|VPN|any|gif|ifb|lo|nflog|nfqueue|stf|tunl|utun"
--pcap_devices_blklist.rmempty = false
pcap_devices_blklist:depends("pcap_capt", "1")

pcap_reading_timeout = s:taboption("adv_set", Value, "pcap_reading_timeout", translate("Pcap Reading Timeout"),
	translate("In milliseconds, with a minimum of 10"))
pcap_reading_timeout.datatype = "min(10)"
pcap_reading_timeout.placeholder = "250"
--pcap_reading_timeout.rmempty = false
pcap_reading_timeout:depends("pcap_capt", "1")

direct_req = s:taboption("adv_set", ListValue, "direct_req", translate("Direct Request"),
	translate("The system needs run in global proxy mode"))
direct_req:value("0", translate("Disable"))
direct_req:value("IPv4")
direct_req:value("IPv6")
direct_req:value("IPv4 + IPv6")

tcp_fast_op = s:taboption("adv_set", Value, "tcp_fast_op", translate("TCP Fast Open"),
	translate("IPv4 support needs Liunx version newer than 3.7. IPv6 TFO support needs Liunx version newer than 3.16"))
tcp_fast_op.datatype = "range(0,32)"
tcp_fast_op:value("0", translate("0 - Disable"))

receive_waiting = s:taboption("adv_set", Value, "receive_waiting", translate("Receive Waiting"),
	translate("In milliseconds, must greater than value of 'Pcap Reading Timeout'"))
receive_waiting.datatype = "ufloat"
receive_waiting:value("", translate("Use Default"))
receive_waiting:value("0", translate("0 - Disable"))

domain_case_conv = s:taboption("adv_set", Flag, "domain_case_conv", translate("Domain Case Conversion"))
domain_case_conv.rmempty = false
--domain_case_conv.default = "1"

header_processing = s:taboption("adv_set", ListValue, "header_processing", translate("DNS Header Processing"))
header_processing:value("0", translate("Disable"))
header_processing:value("cpm", translate("Compression Pointer Mutation"))
header_processing:value("edns", translate("EDNS Label"))
header_processing.rmempty = false

compression_pointer_mutation = s:taboption("adv_set", ListValue, "compression_pointer_mutation", translate("Compression Pointer Mutation"))
compression_pointer_mutation:value("1")
compression_pointer_mutation:value("2")
compression_pointer_mutation:value("3")
compression_pointer_mutation:value("1 + 2")
compression_pointer_mutation:value("2 + 3")
compression_pointer_mutation:value("1 + 3")
compression_pointer_mutation:value("1 + 2 + 3")
compression_pointer_mutation.rmempty = true
compression_pointer_mutation:depends("header_processing", "cpm")

edns_label = s:taboption("adv_set", ListValue, "edns_label", translate("EDNS Label"))
edns_label:value("1", translate("All request to enable"))
edns_label:value("2", translate("Enable request below list"))
edns_label.rmempty = true
edns_label:depends("header_processing", "edns")

edns_list = s:taboption("adv_set", Value, "edns_list", translate("EDNS Label List"),
	translate("Include format: Local + SOCKS Proxy + HTTP CONNECT Proxy + Direct Request + DNSCurve + TCP + UDP")
	.. "<br/>"
	.. translate("Exclude format: All - Local - SOCKS Proxy - HTTP CONNECT Proxy - Direct Request - DNSCurve - TCP - UDP"))
edns_list.placeholder = "DNSCurve + TCP + UDP"
--edns_list.rmempty = false
edns_list:depends("edns_label", "2")

edns_client_subnet_relay = s:taboption("adv_set", Flag, "edns_client_subnet_relay", translate("EDNS Client Subnet Relay"),
	translate("Only enabled when providing services as a non-local private network dns server"))
edns_client_subnet_relay.rmempty = true
edns_client_subnet_relay:depends("edns_label", "1")
edns_client_subnet_relay:depends("edns_label", "2")

dnssec_req = s:taboption("adv_set", Flag, "dnssec_req", translate("DNSSEC Request"))
dnssec_req.rmempty = true
dnssec_req:depends("edns_label", "1")
dnssec_req:depends("edns_label", "2")

dnssec_force_record = s:taboption("adv_set", Flag, "dnssec_force_record", translate("DNSSEC Force Record"),
	translate("Enabling will cause all undeployed DNSSEC function variable name resolution failure!"))
dnssec_force_record.rmempty = true
dnssec_force_record:depends("edns_label", "1")
dnssec_force_record:depends("edns_label", "2")


--[[ Proxy ]]--

--== SOCKS ==---

proxy_socks = s:taboption("proxy_set", Flag, "proxy_socks", translate("SOCKS Proxy"))

proxy_socks_ol = s:taboption("proxy_set", Flag, "proxy_socks_ol", translate("SOCKS Proxy Only"),
	translate("All Non-local requests will only be made via the SOCKS protocol"))
--proxy_socks_ol.rmempty = false
proxy_socks_ol:depends("proxy_socks", "1")

proxy_socks_ver = s:taboption("proxy_set", ListValue, "proxy_socks_ver", translate("SOCKS Version"))
proxy_socks_ver:value("4")
proxy_socks_ver:value("4a")
proxy_socks_ver:value("5")
--proxy_socks_ver.default = "5"
--proxy_socks_ver.rmempty = false
proxy_socks_ver:depends("proxy_socks", "1")

proxy_socks_proto = s:taboption("proxy_set", ListValue, "proxy_socks_proto", translate("SOCKS Protocol"))
proxy_socks_proto:value("IPv4 + TCP")
proxy_socks_proto:value("IPv4 + Force UDP")
proxy_socks_proto:value("IPv4 + TCP + UDP")
proxy_socks_proto:value("IPv6 + TCP")
proxy_socks_proto:value("IPv6 + Force UDP")
proxy_socks_proto:value("IPv6 + TCP + UDP")
proxy_socks_proto:value("IPv4 + IPv6 + TCP")
proxy_socks_proto:value("IPv4 + IPv6 + Force UDP")
proxy_socks_proto:value("IPv4 + IPv6 + TCP + UDP")
--proxy_socks_proto.default = "IPv4 + TCP"
--proxy_socks_proto.rmempty = false
proxy_socks_proto:depends("proxy_socks", "1")

proxy_socks_nohandshake = s:taboption("proxy_set", Flag, "proxy_socks_nohandshake", translate("SOCKS UDP No Handshake"))
--proxy_socks_nohandshake.default = "1"
--proxy_socks_nohandshake.rmempty = false
proxy_socks_nohandshake:depends("proxy_socks", "1")

proxy_socks_ipv4_addr = s:taboption("proxy_set", Value, "proxy_socks_ipv4_addr", translate("SOCKS IPv4 Address"))
proxy_socks_ipv4_addr.placeholder = "127.0.0.1:1080"
--proxy_socks_ipv4_addr.rmempty = false
proxy_socks_ipv4_addr:depends("proxy_socks","1")

proxy_socks_ipv6_addr = s:taboption("proxy_set", Value, "proxy_socks_ipv6_addr", translate("SOCKS IPv6 Address"))
proxy_socks_ipv6_addr.placeholder = "[::1]:1080"
--proxy_socks_ipv6_addr.rmempty = false
proxy_socks_ipv6_addr:depends("proxy_socks","1")

proxy_socks_tg_serv = s:taboption("proxy_set", Value, "proxy_socks_tg_serv", translate("Target DNS Server"))
proxy_socks_tg_serv.placeholder = "8.8.4.4:53"
--proxy_socks_tg_serv.rmempty = false
proxy_socks_tg_serv:depends("proxy_socks","1")

proxy_socks_auth = s:taboption("proxy_set", Flag, "proxy_socks_auth", translate("SOCKS Authorization"))
--proxy_socks_auth.rmempty = false
proxy_socks_auth:depends("proxy_socks", "1")

proxy_socks_user = s:taboption("proxy_set", Value, "proxy_socks_user", translate("SOCKS Username"))
proxy_socks_user.placeholder = translate("Username")
proxy_socks_user:depends("proxy_socks_auth","1")

proxy_socks_pw = s:taboption("proxy_set", Value, "proxy_socks_pw", translate("SOCKS Password"))
proxy_socks_pw.placeholder = translate("Password")
proxy_socks_pw:depends("proxy_socks_auth","1")

--== HTTP ==---

proxy_http = s:taboption("proxy_set", Flag, "proxy_http", translate("HTTP CONNECT Proxy"))

proxy_http_ol = s:taboption("proxy_set", Flag, "proxy_http_ol", translate("HTTP CONNECT Proxy Only"),
	translate("All Non-local requests will only be made via the HTTP CONNECT protocol"))
--proxy_http_ol.rmempty = false
proxy_http_ol:depends("proxy_http", "1")

proxy_http_proto = s:taboption("proxy_set", ListValue, "proxy_http_proto", translate("HTTP CONNECT Protocol"))
proxy_http_proto:value("IPv4")
proxy_http_proto:value("IPv6")
proxy_http_proto:value("IPv4 + IPv6")
--proxy_http_proto.default = "IPv4"
--proxy_http_proto.rmempty = false
proxy_http_proto:depends("proxy_http", "1")

proxy_http_ipv4_addr = s:taboption("proxy_set", Value, "proxy_http_ipv4_addr", translate("HTTP CONNECT IPv4 Address"))
proxy_http_ipv4_addr.placeholder = "127.0.0.1:1080"
--proxy_http_ipv4_addr.rmempty = false
proxy_http_ipv4_addr:depends("proxy_http","1")

proxy_http_ipv6_addr = s:taboption("proxy_set", Value, "proxy_http_ipv6_addr", translate("HTTP CONNECT IPv6 Address"))
proxy_http_ipv6_addr.placeholder = "[::1]:1080"
--proxy_http_ipv6_addr.rmempty = false
proxy_http_ipv6_addr:depends("proxy_http","1")

proxy_http_tg_serv = s:taboption("proxy_set", Value, "proxy_http_tg_serv", translate("Target DNS Server"))
proxy_http_tg_serv.placeholder = "8.8.4.4:53"
--proxy_http_tg_serv.rmempty = false
proxy_http_tg_serv:depends("proxy_http","1")

proxy_http_ver = s:taboption("proxy_set", ListValue, "proxy_http_ver", translate("HTTP CONNECT Version"))
proxy_http_ver:value("0", translate("0 - Auto choice"))
proxy_http_ver:value("1.1")
proxy_http_ver:value("2")
--proxy_http_ver.default = "1.1"
--proxy_http_ver.rmempty = false
proxy_http_ver:depends("proxy_http", "1")

--proxy_http_head = s:taboption("proxy_set", DynamicList, "proxy_http_head", translate("HTTP CONNECT Header Field"),
--	translate("The region can not fill in any of the following fields:")
--	.. "<br/>"
--	.. translate("Connection, Content-Length, Proxy-Connection, Transfer-Encoding, Upgrade"))
--proxy_http_head.optional = true
--proxy_http_head.rmempty = false
--proxy_http_head:depends("proxy_http", "1")

proxy_http_auth = s:taboption("proxy_set", Flag, "proxy_http_auth", translate("HTTP CONNECT Authorization"))
--proxy_http_auth.rmempty = false
proxy_http_auth:depends("proxy_http", "1")

proxy_http_user = s:taboption("proxy_set", Value, "proxy_http_user", translate("HTTP CONNECT Username"))
proxy_http_user.placeholder = translate("Username")
proxy_http_user:depends("proxy_http_auth","1")

proxy_http_pw = s:taboption("proxy_set", Value, "proxy_http_pw", translate("HTTP CONNECT Password"))
proxy_http_pw.placeholder = translate("Password")
proxy_http_pw:depends("proxy_http_auth","1")

--proxy_http_tls = s:taboption("proxy_set", Flag, "proxy_http_tls", translate("Enable TLS Link"))
--proxy_http_tls.rmempty = false
--proxy_http_tls:depends("proxy_http", "1")


--[[ DNSCurve ]]--

dnscurve = s:taboption("dnscurve_set", Flag, "dnscurve", translate("DNSCurve (DNSCrypt)"))

dnscurve_proto = s:taboption("dnscurve_set", ListValue, "dnscurve_proto", translate("DNSCurve Protocol"))
dnscurve_proto:value("IPv4 + UDP")
dnscurve_proto:value("IPv4 + Force TCP")
dnscurve_proto:value("IPv4 + TCP + UDP")
dnscurve_proto:value("IPv6 + UDP")
dnscurve_proto:value("IPv6 + Force TCP")
dnscurve_proto:value("IPv6 + TCP + UDP")
dnscurve_proto:value("IPv4 + IPv6 + UDP")
dnscurve_proto:value("IPv4 + IPv6 + Force TCP")
dnscurve_proto:value("IPv4 + IPv6 + TCP + UDP")
--dnscurve_proto.default = "IPv4 + UDP"
--dnscurve_proto.rmempty = false
dnscurve_proto:depends("dnscurve", "1")

dnscurve_reliable_timeout = s:taboption("dnscurve_set", Value, "dnscurve_reliable_timeout", translate("Reliable DNSCurve Protocol Port Timeout"),
	translate("in milliseconds, minimum to 500"))
dnscurve_reliable_timeout.datatype = "min(500)"
dnscurve_reliable_timeout.placeholder = "3000"
--dnscurve_reliable_timeout.rmempty = false
dnscurve_reliable_timeout:depends("dnscurve","1")

dnscurve_unreliable_timeout = s:taboption("dnscurve_set", Value, "dnscurve_unreliable_timeout", translate("Unreliable DNSCurve Protocol Port Timeout"),
	translate("in milliseconds, minimum to 500"))
dnscurve_unreliable_timeout.datatype = "min(500)"
dnscurve_unreliable_timeout.placeholder = "2000"
--dnscurve_unreliable_timeout.rmempty = false
dnscurve_unreliable_timeout:depends("dnscurve","1")

dnscurve_encrypted = s:taboption("dnscurve_set", Flag, "dnscurve_encrypted", translate("Encryption"))
--dnscurve_encrypted.rmempty = false
dnscurve_encrypted:depends("dnscurve", "1")

dnscurve_one_off_client_key = s:taboption("dnscurve_set", Flag, "dnscurve_one_off_client_key", translate("Client Ephemeral Key"))
--dnscurve_one_off_client_key.rmempty = false
dnscurve_one_off_client_key:depends("dnscurve", "1")

dnscurve_key_recheck_time = s:taboption("dnscurve_set", Value, "dnscurve_key_recheck_time", translate("Server Connection Information Check Interval"),
	translate("In seconds, minimum is 10"))
dnscurve_key_recheck_time.datatype = "min(10)"
dnscurve_key_recheck_time.placeholder = "1800"
--dnscurve_key_recheck_time.rmempty = false
dnscurve_key_recheck_time:depends("dnscurve","1")

dnscurve_serv_input = s:taboption("dnscurve_set", ListValue, "dnscurve_serv_input", translate("Server Input"))
dnscurve_serv_input:value("auto", translate("Database"))
dnscurve_serv_input:value("manual", translate("Addresses"))
--dnscurve_serv_input.default = "database"
--dnscurve_serv_input.rmempty = false
dnscurve_serv_input:depends("dnscurve", "1")

--== Database ==---

dnscurve_serv_db_ipv4 = s:taboption("dnscurve_set", Value, "dnscurve_serv_db_ipv4", translate("IPv4 Main DNS"),
	translatef("The 'Name' field of the corresponding server in the "
		.. "<a href=\"%s\" target=\"_blank\">"
		.. "DNSCurve database</a>", "https://github.com/dyne/dnscrypt-proxy/blob/master/dnscrypt-resolvers.csv"))
dnscurve_serv_db_ipv4:value("cisco")
--dnscurve_serv_db_ipv4.default = "cisco"
--dnscurve_serv_db_ipv4.rmempty = false
dnscurve_serv_db_ipv4:depends("dnscurve_serv_input","auto")

dnscurve_serv_db_ipv4_alt = s:taboption("dnscurve_set", Value, "dnscurve_serv_db_ipv4_alt", translate("IPv4 Alternate DNS"))
dnscurve_serv_db_ipv4_alt:value("d0wn-sg-ns1")
--dnscurve_serv_db_ipv4_alt.rmempty = false
dnscurve_serv_db_ipv4_alt:depends("dnscurve_serv_input","auto")

dnscurve_serv_db_ipv6 = s:taboption("dnscurve_set", Value, "dnscurve_serv_db_ipv6", translate("IPv6 Main DNS"))
dnscurve_serv_db_ipv6:value("cisco-ipv6")
--dnscurve_serv_db_ipv6.default = "cisco-ipv6"
--dnscurve_serv_db_ipv6.rmempty = false
dnscurve_serv_db_ipv6:depends("dnscurve_serv_input","auto")

dnscurve_serv_db_ipv6_alt = s:taboption("dnscurve_set", Value, "dnscurve_serv_db_ipv6_alt", translate("IPv6 Alternate DNS"))
dnscurve_serv_db_ipv6_alt:value("d0wn-sg-ns1-ipv6")
--dnscurve_serv_db_ipv6_alt.rmempty = false
dnscurve_serv_db_ipv6_alt:depends("dnscurve_serv_input","auto")

--== Addresses ==--

---- IPv4 Main ----
dnscurve_serv_addr_ipv4 = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv4", translate("IPv4 Main DNS Address"),
	translatef("More support for DNSCurve (DNSCrypt) servers please move "
		.. "<a href=\"%s\" target=\"_blank\">"
		.. "here</a>", "https://github.com/dyne/dnscrypt-proxy/blob/master/dnscrypt-resolvers.csv"))
dnscurve_serv_addr_ipv4:value("208.67.220.220:443")
--dnscurve_serv_addr_ipv4.default = "208.67.220.220:443"
--dnscurve_serv_addr_ipv4.rmempty = false
dnscurve_serv_addr_ipv4:depends("dnscurve_serv_input","manual")

dnscurve_serv_addr_ipv4_prov = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv4_prov", translate("IPv4 Main Provider Name"))
dnscurve_serv_addr_ipv4_prov:value("2.dnscrypt-cert.opendns.com")
--dnscurve_serv_addr_ipv4_prov.default = "2.dnscrypt-cert.opendns.com"
--dnscurve_serv_addr_ipv4_prov.rmempty = false
dnscurve_serv_addr_ipv4_prov:depends("dnscurve_serv_input","manual")

dnscurve_serv_addr_ipv4_pubkey = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv4_pubkey", translate("IPv4 Main Provider Public Key"))
dnscurve_serv_addr_ipv4_pubkey:value("B735:1140:206F:225D:3E2B:D822:D7FD:691E:A1C3:3CC8:D666:8D0C:BE04:BFAB:CA43:FB79")
--dnscurve_serv_addr_ipv4_pubkey.default = "B735:1140:206F:225D:3E2B:D822:D7FD:691E:A1C3:3CC8:D666:8D0C:BE04:BFAB:CA43:FB79"
--dnscurve_serv_addr_ipv4_pubkey.rmempty = false
dnscurve_serv_addr_ipv4_pubkey:depends("dnscurve_serv_input","manual")

---- IPv4 Alternate ----
dnscurve_serv_addr_ipv4_alt = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv4_alt", translate("IPv4 Alternate DNS Address"))
dnscurve_serv_addr_ipv4_alt:value("128.199.248.105:443")
--dnscurve_serv_addr_ipv4_alt.rmempty = false
dnscurve_serv_addr_ipv4_alt:depends("dnscurve_serv_input","manual")

dnscurve_serv_addr_ipv4_alt_prov = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv4_alt_prov", translate("IPv4 Alternate Provider Name"))
dnscurve_serv_addr_ipv4_alt_prov:value("2.dnscrypt-cert.sg.d0wn.biz")
--dnscurve_serv_addr_ipv4_alt_prov.rmempty = false
dnscurve_serv_addr_ipv4_alt_prov:depends("dnscurve_serv_input","manual")

dnscurve_serv_addr_ipv4_alt_pubkey = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv4_alt_pubkey", translate("IPv4 Alternate Provider Public Key"))
dnscurve_serv_addr_ipv4_alt_pubkey:value("D82B:2B76:1DA0:8470:B55B:820C:FAAB:9F32:D632:E9E0:5616:2CE7:7D21:E970:98FF:4A34")
--dnscurve_serv_addr_ipv4_alt_pubkey.rmempty = false
dnscurve_serv_addr_ipv4_alt_pubkey:depends("dnscurve_serv_input","manual")

---- IPv6 Main ----
dnscurve_serv_addr_ipv6 = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv6", translate("IPv6 Main DNS Address"))
dnscurve_serv_addr_ipv6:value("[2620:0:CCC::2]:443")
--dnscurve_serv_addr_ipv6.default = "[2620:0:CCC::2]:443"
--dnscurve_serv_addr_ipv6.rmempty = false
dnscurve_serv_addr_ipv6:depends("dnscurve_serv_input","manual")

dnscurve_serv_addr_ipv6_prov = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv6_prov", translate("IPv6 Main Provider Name"))
dnscurve_serv_addr_ipv6_prov:value("2.dnscrypt-cert.opendns.com")
--dnscurve_serv_addr_ipv6_prov.default = "2.dnscrypt-cert.opendns.com"
--dnscurve_serv_addr_ipv6_prov.rmempty = false
dnscurve_serv_addr_ipv6_prov:depends("dnscurve_serv_input","manual")

dnscurve_serv_addr_ipv6_pubkey = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv6_pubkey", translate("IPv6 Main Provider Public Key"))
dnscurve_serv_addr_ipv6_pubkey:value("B735:1140:206F:225D:3E2B:D822:D7FD:691E:A1C3:3CC8:D666:8D0C:BE04:BFAB:CA43:FB79")
--dnscurve_serv_addr_ipv6_pubkey.default = "B735:1140:206F:225D:3E2B:D822:D7FD:691E:A1C3:3CC8:D666:8D0C:BE04:BFAB:CA43:FB79"
--dnscurve_serv_addr_ipv6_pubkey.rmempty = false
dnscurve_serv_addr_ipv6_pubkey:depends("dnscurve_serv_input","manual")

---- IPv6 Alternate ----
dnscurve_serv_addr_ipv6_alt = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv6_alt", translate("IPv6 Alternate DNS Address"))
dnscurve_serv_addr_ipv6_alt:value("[2400:6180:0:d0::38:d001]:443")
--dnscurve_serv_addr_ipv6_alt.rmempty = false
dnscurve_serv_addr_ipv6_alt:depends("dnscurve_serv_input","manual")

dnscurve_serv_addr_ipv6_alt_prov = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv6_alt_prov", translate("IPv6 Alternate Provider Name"))
dnscurve_serv_addr_ipv6_alt_prov:value("2.dnscrypt-cert.sg.d0wn.biz")
--dnscurve_serv_addr_ipv6_alt_prov.rmempty = false
dnscurve_serv_addr_ipv6_alt_prov:depends("dnscurve_serv_input","manual")

dnscurve_serv_addr_ipv6_alt_pubkey = s:taboption("dnscurve_set", Value, "dnscurve_serv_addr_ipv6_alt_pubkey", translate("IPv6 Alternate Provider Public Key"))
dnscurve_serv_addr_ipv6_alt_pubkey:value("D82B:2B76:1DA0:8470:B55B:820C:FAAB:9F32:D632:E9E0:5616:2CE7:7D21:E970:98FF:4A34")
--dnscurve_serv_addr_ipv6_alt_pubkey.rmempty = false
dnscurve_serv_addr_ipv6_alt_pubkey:depends("dnscurve_serv_input","manual")


return m
