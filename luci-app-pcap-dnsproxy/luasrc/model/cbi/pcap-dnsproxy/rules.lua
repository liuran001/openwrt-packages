-- Copyright 2017-2018 Dirk Brenken (dev@brenken.org)
-- Copyright 2020 muink <https://github.com/muink>
-- Licensed to the public under the Apache License 2.0

local uci	= require "luci.model.uci".cursor()
local fs	= require("nixio.fs")
local sys	= require("luci.sys")
local util	= require("luci.util")
local packageName = "pcap-dnsproxy"
local conf = packageName
local config = "/etc/config/" .. packageName
local whiteconf = "/etc/pcap-dnsproxy/WhiteList.txt"
local routingconf = "/etc/pcap-dnsproxy/Routing.txt"
local dnscryptconf = "/etc/pcap-dnsproxy/dnscrypt-resolvers.csv"

local whitelist    = translate("WhiteList")
local routinglist  = translate("RoutingList")
local dnscryptdb   = translate("DNSCrypt DB")

local GitReq = tostring(util.trim(sys.exec("git --help >/dev/null 2>/dev/null && echo true")))
local GitReqTitle
if not GitReq or GitReq == "" then
	GitReqTitle = translate("You need install 'git-http' first")
else  
	GitReqTitle = translate("Update")
end


m = Map(conf, "")
m.pageaction = false


local WhiteTime = tostring(util.trim(sys.exec("cat " .. whiteconf .. " | sed -n '4p' | cut -f2 -d: | sed -n '/[0-9]\\+-[0-9]\\+-[0-9]\\+/ p'")))
if not WhiteTime or WhiteTime == "" then WhiteTime = translate("None"); else WhiteTime = WhiteTime .. "    " .. tostring(util.trim(sys.exec("echo $(( $(grep '[^[:space:]]' '" .. whiteconf .. "' | grep -Ev '#|^\\\[' | sed -n '$=') + 0 ))"))) .. " " .. translate("Rules"); end
local DnsCryptDBTime = tostring(util.trim(sys.exec("stat -c '%y' '" .. dnscryptconf .. "' | cut -f1 -d' '")))
if not DnsCryptDBTime or DnsCryptDBTime == "" then DnsCryptDBTime = translate("None"); end



a = m:section(TypedSection, "rule", nil)
a.anonymous = true

aauto = a:option(ListValue, "aauto", translate("Auto Update"))
aauto:value("0", translate("Disable"))
aauto:value("1", translate("General"))
aauto:value("2", translate("Crontab"))
aauto.rmempty = false

aauto_white = a:option(Flag, "aauto_white", translate("Update ") .. whitelist)
aauto_white.rmempty = true
aauto_white:depends("aauto", "1")
aauto_white:depends("aauto", "2")

aauto_white_src = a:option(ListValue, "aauto_white_src", translate("Update Source"))
aauto_white_src:value("main", translate("Main Data source"))
aauto_white_src:value("alt", translate("Alternate Data source"))
aauto_white_src.rmempty = true
aauto_white_src:depends("aauto_white", "1")

aauto_route = a:option(Flag, "aauto_route", translate("Update ") .. routinglist)
aauto_route.rmempty = true
aauto_route:depends("aauto", "1")
aauto_route:depends("aauto", "2")

aauto_cron = a:option(Value, "aauto_cron", translate("Update Schedule"))
aauto_cron.placeholder = "0 9 * * 3"
aauto_cron.rmempty = true
aauto_cron:depends("aauto", "2")

aauto_cycle = a:option(ListValue, "aauto_cycle", translate("Update Cycle"))
aauto_cycle:value("week", translate("Week"))
aauto_cycle:value("month", translate("Month"))
aauto_cycle.rmempty = true
aauto_cycle:depends("aauto", "1")

aauto_week = a:option(ListValue, "aauto_week", translate("Update Date"))
aauto_week:value("0", translate("Sunday"))
aauto_week:value("1", translate("Monday"))
aauto_week:value("2", translate("Tuesday"))
aauto_week:value("3", translate("Wednesday"))
aauto_week:value("4", translate("Thursday"))
aauto_week:value("5", translate("Friday"))
aauto_week:value("6", translate("Saturday"))
aauto_week.rmempty = true
aauto_week:depends("aauto_cycle", "week")

aauto_month = a:option(ListValue, "aauto_month", translate("Update Date"))
aauto_month:value("1", translate("Day 1"))
aauto_month:value("7", translate("Day 7"))
aauto_month:value("14", translate("Day 14"))
aauto_month:value("21", translate("Day 21"))
aauto_month:value("28", translate("Day 28"))
aauto_month.rmempty = true
aauto_month:depends("aauto_cycle", "month")

aauto_time = a:option(ListValue, "aauto_time", translate("Update Time"))
aauto_time:value("0", "0:00")
aauto_time:value("1", "1:00")
aauto_time:value("2", "2:00")
aauto_time:value("3", "3:00")
aauto_time:value("4", "4:00")
aauto_time:value("5", "5:00")
aauto_time:value("6", "6:00")
aauto_time:value("7", "7:00")
aauto_time:value("8", "8:00")
aauto_time:value("9", "9:00")
aauto_time:value("10", "10:00")
aauto_time:value("11", "11:00")
aauto_time:value("12", "12:00")
aauto_time:value("13", "13:00")
aauto_time:value("14", "14:00")
aauto_time:value("15", "15:00")
aauto_time:value("16", "16:00")
aauto_time:value("17", "17:00")
aauto_time:value("18", "18:00")
aauto_time:value("19", "19:00")
aauto_time:value("20", "20:00")
aauto_time:value("21", "21:00")
aauto_time:value("22", "22:00")
aauto_time:value("23", "23:00")
aauto_time.rmempty = true
aauto_time:depends("aauto", "1")

aauto_apply = a:option(Button, "_aauto_apply", translate("Save & Apply"))
aauto_apply.inputtitle = translate("Save & Apply")
aauto_apply.inputstyle = "apply"
aauto_apply.write = function()
    --m.uci:save(conf)
    m.uci:commit(conf)
    m.uci:apply()
	sys.call ("/usr/bin/pcap-dnsproxy.sh schedule")
end


w = m:section(TypedSection, "rule", whitelist)
w.anonymous = true

wstate = w:option(DummyValue, "_wstate", translate("Last update"))
wstate.template = packageName .. "/status"
wstate.value = WhiteTime

wclear = w:option(Button, "_wclear", translate("List Cleanup"))
wclear.inputtitle = translate("Cleanup")
wclear.inputstyle = "apply"
function wclear.write(self, section)
	fs.writefile(whiteconf, "\n")
end

wurl = w:option(ListValue, "white_url", translate("Main Data source"),
	translate("Fast in China but not provide Zip download"))
wurl:value("https://gitee.com/felixonmars/dnsmasq-china-list.git", "Git: " .. "dnsmasq-china-list" .. " - " .. translate("Gitee"))
wurl:value("https://code.aliyun.com/felixonmars/dnsmasq-china-list.git", "Git: " .. "dnsmasq-china-list" .. " - " .. translate("Aliyun"))
wurl:value("https://codehub.devcloud.huaweicloud.com/dnsmasq-china-list00001/dnsmasq-china-list.git", "Git: " .. "dnsmasq-china-list" .. " - " .. translate("HuaweiCloud"))
wurl.rmempty = false

wup = w:option(Button, "_wup", translate("Update ") .. whitelist)
wup.inputtitle = GitReqTitle
wup.inputstyle = "apply"
function wup.write (self, section)
	m.uci:apply()
	if GitReq and not (GitReq == "") then
		sys.call ("/usr/bin/pcap-dnsproxy.sh update_white_full main")
	end
end

walturl = w:option(ListValue, "alt_white_url", translate("Alternate Data source"),
	translate("Just in case if you can't use 'git-http'"))
walturl:value("https://github.com/felixonmars/dnsmasq-china-list/archive/master.zip", "Zip: " .. "dnsmasq-china-list" .. " - " .. "GitHub")
walturl:value("https://gitlab.com/felixonmars/dnsmasq-china-list/-/archive/master/dnsmasq-china-list-master.zip", "Zip: " .. "dnsmasq-china-list" .. " - " .. "GitLab")
walturl:value("https://github.com/muink/dnsmasq-china-tool/archive/list.zip", "Zip: " .. "dnsmasq-china-tool" .. " - " .. "GitHub")
walturl.rmempty = false

waltup = w:option(Button, "_waltup", translate("Alternate Update ") .. whitelist)
waltup.inputtitle = translate("Update")
waltup.inputstyle = "apply"
function waltup.write (self, section)
	m.uci:apply()
	sys.call ("/usr/bin/pcap-dnsproxy.sh update_white_full alt")
end

wsave = w:option(Button, "_wsave", translate("Save & Apply"))
wsave.inputtitle = translate("Save & Apply")
wsave.inputstyle = "apply"
wsave.write = function()
    m.uci:apply()
	sys.call ("/usr/bin/pcap-dnsproxy.sh schedule")
end


local RoutingTime = tostring(util.trim(sys.exec("cat " .. routingconf .. " | sed -n '5p' | cut -f2 -d: | sed -n '/[0-9]\\+-[0-9]\\+-[0-9]\\+/ p'")))
if not RoutingTime or RoutingTime == "" then RoutingTime = translate("None"); else RoutingTime = RoutingTime 
	.. "    " .. "IPv4: " .. tostring(util.trim(sys.exec("echo $(( $(sed -n '/^## IPv4/,/^## .*/ p' '" .. routingconf .. "' | grep '[^[:space:]]' | grep -Ev '#|^\\\[' | sed -n '$=') + 0 ))"))) .. " " .. translate("Rules") 
	.. "    " .. "IPv6: " .. tostring(util.trim(sys.exec("echo $(( $(sed -n '/^## IPv6/,/^## .*/ p' '" .. routingconf .. "' | grep '[^[:space:]]' | grep -Ev '#|^\\\[' | sed -n '$=') + 0 ))"))) .. " " .. translate("Rules");
end

r = m:section(TypedSection, "rule", routinglist)
r.anonymous = true

rstate = r:option(DummyValue, "_rstate", translate("Last update"))
rstate.template = packageName .. "/status"
rstate.value = RoutingTime

rclear = r:option(Button, "_rclear", translate("List Cleanup"))
rclear.inputtitle = translate("Cleanup")
rclear.inputstyle = "apply"
function rclear.write(self, section)
	fs.writefile(routingconf, "\n")
end

rurl = r:option(ListValue, "routing_url", translate("IPv4 Data source"))
rurl:value("https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest", "APNIC")
rurl:value("https://www.ipdeny.com/ipblocks/data/aggregated/cn-aggregated.zone", "IPdeny")
rurl:value("https://github.com/17mon/china_ip_list/archive/master.zip", "IPIP")
rurl:value("https://github.com/metowolf/iplist/raw/master/data/special/china.txt", "CZ88")
rurl:value("https://github.com/gaoyifan/china-operator-ip/archive/ip-lists.zip", "china-operator-ip")
rurl.rmempty = false

rv6url = r:option(ListValue, "routing_v6_url", translate("IPv6 Data source"))
rv6url:value("https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest", "APNIC")
rv6url:value("https://www.ipdeny.com/ipv6/ipaddresses/aggregated/cn-aggregated.zone", "IPdeny")
rv6url:value("https://github.com/gaoyifan/china-operator-ip/archive/ip-lists.zip", "china-operator-ip")
rv6url.rmempty = false

rup = r:option(Button, "_rup", translate("Update ") .. routinglist)
rup.inputtitle = translate("Update")
rup.inputstyle = "apply"
function rup.write (self, section)
	m.uci:apply()
	sys.call ("/usr/bin/pcap-dnsproxy.sh update_routing_full")
end

rsave = r:option(Button, "_rsave", translate("Save & Apply"))
rsave.inputtitle = translate("Save & Apply")
rsave.inputstyle = "apply"
rsave.write = function()
    m.uci:apply()
	sys.call ("/usr/bin/pcap-dnsproxy.sh schedule")
end


d = m:section(TypedSection, "rule", dnscryptdb)
d.anonymous = true

dstate = d:option(DummyValue, "_dstate", translate("Last update"))
dstate.template = packageName .. "/status"
dstate.value = DnsCryptDBTime

dup = d:option(Button, "_dup", translate("Update ") .. dnscryptdb)
dup.inputtitle = translate("Update")
dup.inputstyle = "apply"
function dup.write (self, section)
	sys.call ("curl -Lo '" .. dnscryptconf .. "' 'https://raw.githubusercontent.com/dyne/dnscrypt-proxy/master/dnscrypt-resolvers.csv'")
end


return m
