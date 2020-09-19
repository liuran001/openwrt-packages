#!/bin/bash
# Copyright (C) 2020 muink <https://github.com/muink>
# This is free software, licensed under the Apache License, Version 2.0

. /lib/functions.sh

UCICFGFILE=pcap-dnsproxy # Package name
TYPEDSECTION=main
TYPEDSECTION2=rule
CONFDIR=/etc/pcap-dnsproxy

RAWCONFIGFILE=$CONFDIR/Config.conf-opkg
CONFIGFILE=$CONFDIR/Config.conf
USERCONFIG=$CONFDIR/user/Config
RAWHOSTSFILE=$CONFDIR/Hosts.conf-opkg
HOSTSFILE=$CONFDIR/Hosts.conf
USERHOSTS=$CONFDIR/user/Hosts
RAWIPFILTERFILE=$CONFDIR/IPFilter.conf-opkg
IPFILTERFILE=$CONFDIR/IPFilter.conf
USERIPFILTER=$CONFDIR/user/IPFilter
WHITELIST=$CONFDIR/WhiteList.txt
ROUTINGLIST=$CONFDIR/Routing.txt

_FUNCTION="$1"; shift
# _PARAMETERS: "$@"



# map_def [<type>]
# type:    <nam|map>
map_def() {
local __cmd

# map_def					-- List  ALL  element
if   [ -z "$1" ]; then __cmd=;
# map_def nam				-- List 'nam' element
elif [ "$1" == "nam" ]; then __cmd="| cut -f1 -d=";
# map_def map				-- List 'map' element
elif [ "$1" == "map" ]; then __cmd="| cut -f2 -d=";
# <type> not support
else >&2 echo 'map_def: The <type> parameter is invalid'; return 1;
fi

# Map name list
eval cat <<-MAPLIST $__cmd
	CONF_BASE="Base"
	CONF_LOG="Log"
	CONF_LISTEN="Listen"
	CONF_DNS="DNS"
	CONF_LOCALDNS="Local DNS"
	CONF_ADDRESSES="Addresses"
	CONF_VALUES="Values"
	CONF_SWITCHES="Switches"
	CONF_DATA="Data"
	CONF_PROXY="Proxy"
	CONF_DNSCURVE="DNSCurve"
	CONF_DNSCURVEDB="DNSCurve Database"
	CONF_DNSCURVEADDR="DNSCurve Addresses"
	CONF_DNSCURVEKEY="DNSCurve Keys"
	CONF_DNSCURVEMAGCNUM="DNSCurve Magic Number"
MAPLIST
}

# map_tab <mapname> [<variabletype>] [<element>]
# variabletype:    <uci|raw>
map_tab() {
if [ -z "$1" ]; then >&2 echo 'map_tab: The <mapname> requires an argument'; return 1; fi
local _map="$1"
local _vtype="$2"
local _element="$3"
local __cmd


# <element> not support
if   [ "$_element" == "NONE" ]; then >&2 echo 'map_tab: The <element> parameter is invalid'; return 1;
# <element> empty
elif [ -z "$_element" ]; then
	# map_tab "$CONF_DNS"						-- List  ALL  element of maptab '$CONF_DNS'; keep'NONE'; keep function
	if   [ -z "$_vtype" ]; then __cmd=;
	# map_tab "$CONF_DNS" uci					-- List 'uci' element of maptab '$CONF_DNS'; ignore uci'NONE'; ignore uci'MULTICONF'; ignore raw2uci function
	elif [ "$_vtype" == "uci" ]; then __cmd="| cut -f1 -d@ | grep -v '^NONE$' | grep -v '^MULTICONF$' | grep -v '^_.\+'";
	# map_tab "$CONF_DNS" raw					-- List 'raw' element of maptab '$CONF_DNS'; ignore raw'NONE'; ignore uci2raw function
	elif [ "$_vtype" == "raw" ]; then __cmd="| cut -f2 -d@ | grep -v '^NONE$' | grep -v '^_.\+'";
	# <variabletype> not support
	else >&2 echo 'map_tab: The <variabletype> parameter is invalid'; return 1;
	fi
# <element> not empty
else
	# map_tab "$CONF_DNS" '' "$_element"		-- Show relative element for value '$_element' of maptab '$CONF_DNS'; keep'NONE'
	if   [ -z "$_vtype" ]; then __cmd="| sed -n -e \"/^\${_element}@/ {s/\$_element//; s/@//p}\" -e \"/@\${_element}\$/ {s/\$_element//; s/@//p}\"";
	# map_tab "$CONF_DNS" uci "$_element"		-- Show 'uci' element for value '$_element' of maptab '$CONF_DNS'; keep'NONE'
	elif [ "$_vtype" == "uci" ]; then __cmd="| sed -n -e \"/^\${_element}@/ p\" -e \"/@\${_element}\$/ p\" | cut -f1 -d@";
	# map_tab "$CONF_DNS" raw "$_element"		-- Show 'raw' element for value '$_element' of maptab '$CONF_DNS'; keep'NONE'
	elif [ "$_vtype" == "raw" ]; then __cmd="| sed -n -e \"/^\${_element}@/ p\" -e \"/@\${_element}\$/ p\" | cut -f2 -d@";
	# <variabletype> not support
	else >&2 echo 'map_tab: The <variabletype> parameter is invalid'; return 1;
	fi
fi


case "$_map" in
	'')
		>&2 echo 'map_tab: The <mapname> requires an argument'
		return 1
	;;
	"uci_$TYPEDSECTION2")
		eval grep \"\$_element\" <<-EOF $__cmd
			aauto@NONE
			aauto_white@NONE
			aauto_white_src@NONE
			aauto_route@NONE
			aauto_cron@NONE
			aauto_cycle@NONE
			aauto_week@NONE
			aauto_month@NONE
			aauto_time@NONE
			white_url@NONE
			alt_white_url@NONE
			routing_url@NONE
			routing_v6_url@NONE
		EOF
	;;
	"$CONF_BASE")
		eval grep \"\$_element\" <<-EOF $__cmd
			cfg_ver@Version
			cfg_refsh_time@File Refresh Time
			large_buff_size@Large Buffer Size
			additional_path@Additional Path
			hosts_cfg_name@Hosts File Name
			ipfilter_file_name@IPFilter File Name
		EOF
	;;
	"$CONF_LOG")
		eval grep \"\$_element\" <<-EOF $__cmd
			log_lev@Print Log Level
			log_max_size@Log Maximum Size
		EOF
	;;
	"$CONF_LISTEN")
		eval grep \"\$_element\" <<-EOF $__cmd
			NONE@Process Unique
			pcap_capt@Pcap Capture
			pcap_devices_blklist@Pcap Devices Blacklist
			pcap_reading_timeout@Pcap Reading Timeout
			listen_proto@Listen Protocol
			listen_port@Listen Port
			operation_mode@Operation Mode
			NONE@IPFilter Type
			NONE@IPFilter Level
			NONE@Accept Type
		EOF
	;;
	"$CONF_DNS")
		eval grep \"\$_element\" <<-EOF $__cmd
			global_proto@Outgoing Protocol
			direct_req@Direct Request
			cc_type@Cache Type
			cc_parameter@Cache Parameter
			NONE@Cache Single IPv4 Address Prefix
			NONE@Cache Single IPv6 Address Prefix
			cc_default_ttl@Default TTL
		EOF
	;;
	"$CONF_LOCALDNS")
		eval grep \"\$_element\" <<-EOF $__cmd
			ll_proto@Local Protocol
			ll_filter_mode@__FUNCTION='if [ "\$ll_filter_mode" == "0" ]; then echo Local Hosts=0; echo Local Routing=0; ll_force_req=0; elif [ "\$ll_filter_mode" == "hostlist" ]; then echo Local Hosts=1; echo Local Routing=0; elif [ "\$ll_filter_mode" == "routing" ]; then echo Local Hosts=0; echo Local Routing=1; ll_force_req=0; fi'
			__FUNCTION='if [ "\$_value" == "1" ]; then echo ll_filter_mode=hostlist; else echo ll_filter_mode=0; fi'@Local Hosts
			__FUNCTION='if [ "\$_value" == "1" ]; then echo ll_filter_mode=routing; fi'@Local Routing
			ll_force_req@Local Force Request
		EOF
	;;
	"$CONF_ADDRESSES")
		eval grep \"\$_element\" <<-EOF $__cmd
			ipv4_listen_addr@IPv4 Listen Address
			edns_client_subnet_ipv4_addr@IPv4 EDNS Client Subnet Address
			global_ipv4_addr@IPv4 Main DNS Address
			global_ipv4_addr_alt@IPv4 Alternate DNS Address
			ll_ipv4_addr@IPv4 Local Main DNS Address
			ll_ipv4_addr_alt@IPv4 Local Alternate DNS Address
			ipv6_listen_addr@IPv6 Listen Address
			edns_client_subnet_ipv6_addr@IPv6 EDNS Client Subnet Address
			global_ipv6_addr@IPv6 Main DNS Address
			global_ipv6_addr_alt@IPv6 Alternate DNS Address
			ll_ipv6_addr@IPv6 Local Main DNS Address
			ll_ipv6_addr_alt@IPv6 Local Alternate DNS Address
		EOF
	;;
	"$CONF_VALUES")
		eval grep \"\$_element\" <<-EOF $__cmd
			NONE@Thread Pool Base Number
			NONE@Thread Pool Maximum Number
			NONE@Thread Pool Reset Time
			NONE@Queue Limits Reset Time
			NONE@EDNS Payload Size
			ipv4_packet_ttl@IPv4 Packet TTL
			global_ipv4_ttl@IPv4 Main DNS TTL
			global_ipv4_ttl_alt@IPv4 Alternate DNS TTL
			ipv6_packet_ttl@IPv6 Packet Hop Limits
			global_ipv6_ttl@IPv6 Main DNS Hop Limits
			global_ipv6_ttl_alt@IPv6 Alternate DNS Hop Limits
			ttl_tolerance@Hop Limits Fluctuation
			reliable_once_socket_timeout@Reliable Once Socket Timeout
			reliable_serial_socket_timeout@Reliable Serial Socket Timeout
			unreliable_once_socket_timeout@Unreliable Once Socket Timeout
			unreliable_serial_socket_timeout@Unreliable Serial Socket Timeout
			tcp_fast_op@TCP Fast Open
			receive_waiting@Receive Waiting
			icmp_test@ICMP Test
			domain_test@Domain Test
			alt_times@Alternate Times
			alt_times_range@Alternate Time Range
			alt_reset_time@Alternate Reset Time
			mult_req_time@Multiple Request Times
		EOF
	;;
	"$CONF_SWITCHES")
		eval grep \"\$_element\" <<-EOF $__cmd
			domain_case_conv@Domain Case Conversion
			header_processing@__FUNCTION='if [ "\$header_processing" == "0" ]; then compression_pointer_mutation=0; edns_label=0; elif [ "\$header_processing" == "cpm" ]; then edns_label=0; elif [ "\$header_processing" == "edns" ]; then compression_pointer_mutation=0; fi'
			compression_pointer_mutation@__FUNCTION='echo Compression Pointer Mutation=\$compression_pointer_mutation'
			__FUNCTION='if [ -z "\$_value" -o "\$_value" == "0" ]; then echo header_processing=0; else echo header_processing=cpm; echo compression_pointer_mutation=\$_value; fi'@Compression Pointer Mutation
			edns_label@__FUNCTION='if [ "\$edns_label" == "0" ]; then echo EDNS Label=0; elif [ "\$edns_label" == "1" ]; then echo EDNS Label=1; elif [ "\$edns_label" == "2" ]; then echo EDNS Label=\$edns_list; fi'
			edns_list@NONE
			__FUNCTION='if [ -z "\$_value" -o "\$_value" == "0" ]; then echo edns_label=0; elif [ "\$_value" == "1" ]; then echo header_processing=edns; echo edns_label=1; else echo header_processing=edns; echo edns_label=2; echo edns_list=\$_value; fi'@EDNS Label
			edns_client_subnet_relay@EDNS Client Subnet Relay
			dnssec_req@DNSSEC Request
			dnssec_force_record@DNSSEC Force Record
			NONE@Alternate Multiple Request
			NONE@IPv4 Do Not Fragment
			NONE@TCP Data Filter
			NONE@DNS Data Filter
			NONE@Blacklist Filter
			NONE@Resource Record Set TTL Filter
		EOF
	;;
	"$CONF_DATA")
		eval grep \"\$_element\" <<-EOF $__cmd
			NONE@ICMP ID
			NONE@ICMP Sequence
			NONE@ICMP PaddingData
			NONE@Domain Test Protocol
			NONE@Domain Test ID
			NONE@Domain Test Data
			server_domain@Local Machine Server Name
		EOF
	;;
	"$CONF_PROXY")
		eval grep \"\$_element\" <<-EOF $__cmd
			proxy_socks@SOCKS Proxy
			proxy_socks_ver@SOCKS Version
			proxy_socks_proto@SOCKS Protocol
			proxy_socks_nohandshake@SOCKS UDP No Handshake
			proxy_socks_ol@SOCKS Proxy Only
			proxy_socks_ipv4_addr@SOCKS IPv4 Address
			proxy_socks_ipv6_addr@SOCKS IPv6 Address
			proxy_socks_tg_serv@SOCKS Target Server
			proxy_socks_user@SOCKS Username
			proxy_socks_pw@SOCKS Password
			proxy_http@HTTP CONNECT Proxy
			proxy_http_proto@HTTP CONNECT Protocol
			proxy_http_ol@HTTP CONNECT Proxy Only
			proxy_http_ipv4_addr@HTTP CONNECT IPv4 Address
			proxy_http_ipv6_addr@HTTP CONNECT IPv6 Address
			proxy_http_tg_serv@HTTP CONNECT Target Server
			NONE@HTTP CONNECT TLS Handshake
			NONE@HTTP CONNECT TLS Version
			NONE@HTTP CONNECT TLS Validation
			NONE@HTTP CONNECT TLS Server Name Indication
			NONE@HTTP CONNECT TLS ALPN
			proxy_http_ver@HTTP CONNECT Version
			MULTICONF@HTTP CONNECT Header Field
			proxy_http_auth@__FUNCTION='if [ "\$proxy_http_auth" == "0" ]; then echo HTTP CONNECT Proxy Authorization=; elif [ "\$proxy_http_auth" == "1" ]; then echo HTTP CONNECT Proxy Authorization=\$proxy_http_user:\$proxy_http_pw; fi'
			proxy_http_user@NONE
			proxy_http_pw@NONE
			__FUNCTION='if [ -n "\$(echo \$_value|sed -n "/^.*:.*\$/ p")" ]; then echo proxy_http_auth=1; echo proxy_http_user=\${_value%%:*}; echo proxy_http_pw=\${_value##*:}; else echo proxy_http_auth=0; fi'@HTTP CONNECT Proxy Authorization
		EOF
	;;
	"$CONF_DNSCURVE")
		eval grep \"\$_element\" <<-EOF $__cmd
			dnscurve@DNSCurve
			dnscurve_proto@DNSCurve Protocol
			NONE@DNSCurve Payload Size
			dnscurve_reliable_timeout@DNSCurve Reliable Socket Timeout
			dnscurve_unreliable_timeout@DNSCurve Unreliable Socket Timeout
			dnscurve_encrypted@DNSCurve Encryption
			NONE@DNSCurve Encryption Only
			dnscurve_one_off_client_key@DNSCurve Client Ephemeral Key
			dnscurve_key_recheck_time@DNSCurve Key Recheck Time
		EOF
	;;
	"$CONF_DNSCURVEDB")
		eval grep \"\$_element\" <<-EOF $__cmd
			NONE@DNSCurve Database Name
			dnscurve_serv_db_ipv4@DNSCurve Database IPv4 Main DNS
			dnscurve_serv_db_ipv4_alt@DNSCurve Database IPv4 Alternate DNS
			dnscurve_serv_db_ipv6@DNSCurve Database IPv6 Main DNS
			dnscurve_serv_db_ipv6_alt@DNSCurve Database IPv6 Alternate DNS
		EOF
	;;
	"$CONF_DNSCURVEADDR")
		eval grep \"\$_element\" <<-EOF $__cmd
			dnscurve_serv_addr_ipv4@DNSCurve IPv4 Main DNS Address
			dnscurve_serv_addr_ipv4_alt@DNSCurve IPv4 Alternate DNS Address
			dnscurve_serv_addr_ipv6@DNSCurve IPv6 Main DNS Address
			dnscurve_serv_addr_ipv6_alt@DNSCurve IPv6 Alternate DNS Address
			dnscurve_serv_addr_ipv4_prov@DNSCurve IPv4 Main Provider Name
			dnscurve_serv_addr_ipv4_alt_prov@DNSCurve IPv4 Alternate Provider Name
			dnscurve_serv_addr_ipv6_prov@DNSCurve IPv6 Main Provider Name
			dnscurve_serv_addr_ipv6_alt_prov@DNSCurve IPv6 Alternate Provider Name
		EOF
	;;
	"$CONF_DNSCURVEKEY")
		eval grep \"\$_element\" <<-EOF $__cmd
			NONE@DNSCurve Client Public Key
			NONE@DNSCurve Client Secret Key
			dnscurve_serv_addr_ipv4_pubkey@DNSCurve IPv4 Main DNS Public Key
			dnscurve_serv_addr_ipv4_alt_pubkey@DNSCurve IPv4 Alternate DNS Public Key
			dnscurve_serv_addr_ipv6_pubkey@DNSCurve IPv6 Main DNS Public Key
			dnscurve_serv_addr_ipv6_alt_pubkey@DNSCurve IPv6 Alternate DNS Public Key
			NONE@DNSCurve IPv4 Main DNS Fingerprint
			NONE@DNSCurve IPv4 Alternate DNS Fingerprint
			NONE@DNSCurve IPv6 Main DNS Fingerprint
			NONE@DNSCurve IPv6 Alternate DNS Fingerprint
		EOF
	;;
	"$CONF_DNSCURVEMAGCNUM")
		eval grep \"\$_element\" <<-EOF $__cmd
			NONE@DNSCurve IPv4 Main Receive Magic Number
			NONE@DNSCurve IPv4 Alternate Receive Magic Number
			NONE@DNSCurve IPv6 Main Receive Magic Number
			NONE@DNSCurve IPv6 Alternate Receive Magic Number
			NONE@DNSCurve IPv4 Main DNS Magic Number
			NONE@DNSCurve IPv4 Alternate DNS Magic Number
			NONE@DNSCurve IPv6 Main DNS Magic Number
			NONE@DNSCurve IPv6 Alternate DNS Magic Number
		EOF
	;;
	*)
		>&2 echo "map_tab: The Map \"$_map\" does not exist"
		return 1
	;;
esac

}

# format_str <string>
format_str() {

echo $1 | sed -n "s|\\\\|\\\\\\\\|g p"

#\n
#\\\n
#\\\\\\\n
#\\\\\\\\\\\\\\\n

#\\
#\\\\
#\\\\\\\\
#\\\\\\\\\\\\\\\\

# $ --> \$ --> \\\$ --> \\\\\\\$ --> \\\\\\\\\\\\\\\$ --> \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\$
# 0      1        3            7                    15                                   31
# N=2^n-1

# \ --> \\ --> \\\\ --> \\\\\\\\ --> \\\\\\\\\\\\\\\\ --> \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
# 0      2        4            8                    16                                   32
# N=2^n

}

function reservice() {
	local service="$1"
	local action="$2"
	echo "${action^}ing ${service} service..."
	if hash service 2>/dev/null; then
		service ${service} ${action}
	elif hash busybox 2>/dev/null && [[ -d "/etc/init.d" ]]; then
		/etc/init.d/${service} ${action}
	else
		echo "Now please ${action} ${service} since I don't know how to do it."
	fi
}

# daemon_oper <add|remove>
daemon_oper() {
	local serv='/etc/init.d/pcap-dnsproxy start'
	local target='/etc/crontabs/root'
	local dln=$(grep -n "$serv" $target 2>/dev/null | cut -f1 -d':')

	if   [ "$1" == "add" ]; then grep "$serv" $target >/dev/null 2>/dev/null || echo "*/5 * * * * $serv" >> $target;
	elif [ "$1" == "remove" ]; then
		if [ -n "$dln" ]; then
			dln=$(echo $dln | sed -E "s|([0-9]+)|\1d;|g")
			eval "sed -i \"$dln\" $target"
		fi
	fi
}

# uci2conf <section> <mapname> <conffile>
uci2conf() {
	local initvar=(section map config)
	for _var in "${initvar[@]}"; do
		if [ -z "$1" ]; then >&2 echo "uci2conf: The <$_var> requires an argument"; return 1;
		else eval "local \$_var=\"\$1\"" && shift; fi
	done


#config_load $UCICFGFILE

# Defining variables for uci config
#cat <<< `map_tab "$@"` | sed -n "s/^/'/; s/$/'/ p"
local uci_list=`map_tab "$map" uci | sed -n "s/^/'/; s/$/'/ p"` # "$@"
	eval uci_list=(${uci_list//'/\'})
local uci_count=${#uci_list[@]}
# Get values of uci config
for _var in "${uci_list[@]}"; do local $_var; config_get "$_var" "$section" "$_var"; done
#config_set "$section" "$_var" "${!_var}" # Only set to environment variables


# Write $config file
local command
local araw_list
local _raw
local __FUNCTION

for _var in "${uci_list[@]}"; do
	# <$_var> not empty AND <$$_var> not empty
	if [ -n "$_var" -a -n "${!_var}" ]; then

		_raw=`map_tab "$map" raw "$_var"` # ~~Also need process DynamicList like: 'HTTP CONNECT Header Field'~~ Consider not adding, can only added them from user conffile

		# <$_raw> returns not empty
		if [ -n "$_raw" ]; then
			# Not Normal uci element
			if   [ "`echo "$_raw" | grep "^__.\+$"`" ]; then
				# Function uci element
				eval "$_raw" # Extract function body
					#eval "echo '$__FUNCTION'"
				eval "$__FUNCTION" >/dev/null
				araw_list=`eval "$__FUNCTION" | sed -n "s/^/'/; s/$/'/ p"` # "$@"
					eval araw_list=(${araw_list//'/\'})

				# Write Function conf
				for _tab in "${araw_list[@]}"; do
					command="$command s~^\($(echo "$_tab" | cut -f1 -d=)\) \([<=>]\).*\$~\1 \2 $(echo "$_tab" | cut -f2 -d=)~;"
					#echo "Function: $(echo "$_tab" | cut -f1 -d=) = $(echo "$_tab" | cut -f2 -d=)" #debug test
				done
			# All-in-one uci element
			elif [ "$_raw" == "NONE" ]; then
				echo "Usually used to combine multiple uci parameters into one raw parameter" >/dev/null
			# Normal uci element
			else
				# Write Normal conf
				_var="${!_var}"
				command="$command s~^\($_raw\) \([<=>]\).*\$~\1 \2 ${_var}~;"
				#echo "Normal: ${_raw} = ${_var}" #debug test
			fi
		# <$_raw> returns empty
		else
			>&2 echo "uci2conf: The Element \"$_var\" not have relative element"; return 1
			>&2 echo "This situation basically does not exist" >/dev/null
		fi

	# <$_var> returns empty
	else
		echo "uci2conf: The Element \"$_var\" is empty" >/dev/null
	fi
done
		#echo "$command"

	if   [ "$map" == "${!CONF_LIST_FIRST}" ]; then sed -i "1,/^\[.*\]$/            { $command }" $config;
	elif [ "$map" == "${!CONF_LIST_LAST}" ]; then  sed -i "/^\[$map\]$/,$          { $command }" $config;
	else                                                       sed -i "/^\[$map\]$/,/^\[.*\]$/ { $command }" $config;
	fi

}

# conf2uci <section> <mapname> <conffile> <pkgname>
conf2uci() {
	local initvar=(section map config pkgnm)
	for _var in "${initvar[@]}"; do
		if [ -z "$1" ]; then >&2 echo "uci2conf: The <$_var> requires an argument"; return 1;
		else eval "local \$_var=\"\$1\"" && shift; fi
	done


# Defining variables for conffile
#cat <<< `map_tab "$@"` | sed -n "s/^/'/; s/$/'/ p"
local raw_list=`map_tab "$map" raw | sed -n "s/^/'/; s/$/'/ p"` # "$@"
	eval raw_list=(${raw_list//'/\'})
local raw_count=${#raw_list[@]}
#for _ll in "${raw_list[@]}"; do echo "$_ll"; done


# Write uci settings $section
local command
local araw_list
local _uci
local _value
local __FUNCTION

for _var in "${raw_list[@]}"; do

	_uci=`map_tab "$map" uci "$_var"`

	# <$_var> not empty AND relative uci element not empty
	if [ -n "$_var" -a -n "$_uci" ]; then

		_value="$(sed -n "/^\[${map}\]$/,/^\[.*\]$/ { s~^${_var} [<=>][ \t]*\(.*\)$~\1~ p }" $config)"

		# Not Normal raw element
		if   [ "`echo "$_uci" | grep "^__.\+$"`" ]; then
			# Function raw element
			eval "$_uci" # Extract function body
				#eval "echo '$__FUNCTION'"
			araw_list=`eval "$__FUNCTION" | sed -n "s/^/'/; s/$/'/ p"` # "$@"
				eval araw_list=(${araw_list//'/\'})

			# Write Function conf
			for _tab in "${araw_list[@]}"; do
				uci_set "$pkgnm" "$section" "$(echo "$_tab" | cut -f1 -d=)" "$(echo "$_tab" | cut -f2 -d=)"
				#echo "Function: $(echo "$_tab" | cut -f1 -d=) = $(echo "$_tab" | cut -f2 -d=)" #debug test
			done
		# Undefined raw element
		elif [ "$_uci" == "NONE" -o "$_uci" == "MULTICONF" ]; then
			echo "The relative uci element value of \"$_raw\" is undefined" >/dev/null
		# Normal raw element
		else
			# Write Normal uci
			uci_set "$pkgnm" "$section" "$_uci" "$_value"
			#echo "Normal: ${_uci} = ${_value}" #debug test
		fi

	# <$_var> OR <$_uci> returns empty
	else
		>&2 echo "conf2uci: The Element \"$_var\" not exist or not have relative element"; return 1
		>&2 echo "This situation basically does not exist" >/dev/null
	fi
done

	uci_commit

}

# userconf <userconffile> <systemconffile>
userconf() {
	local initvar=(userconf sysconf)
	for _var in "${initvar[@]}"; do
		if [ -z "$1" ]; then >&2 echo "userconf: The <$_var> requires an argument"; return 1;
		else eval "local \$_var=\"\$1\"" && shift; fi
	done


# Verify head validity
local map_list=$(echo `map_def map` | sed -n "s|\" \"|$\|^|g; s|^\"|^|; s|\"$|$| p") # reference
local bad_head=$(
	sed -n "/^\[.*\][ \t]*$/ { s|^\[\(.*\)\][ \t]*$|\1|g p }" "$userconf" |
	grep -Ev "$map_list" |
	sed -n "s/^/'/; s/$/'/ p"
)
	eval bad_head=(${bad_head//'/\'})

# Note "Bad Head"
local _badhead
for _badhead in "${bad_head[@]}"; do
	sed -i "/^\[$_badhead\][ \t]*$/,/^\[.*\][ \t]*$/ { s|^\(\[$_badhead\]\)|#\1|; s|^\([^\[#]\)|#\1|g; }" "$userconf"
done


# Verify parameter validity
local valid_head=$(sed -n "/^\[.*\][ \t]*$/ { s|^\[\(.*\)\][ \t]*$|'\1'|g p }" "$userconf")
	eval valid_head=(${valid_head//'/\'})

local refer
local bad_param
local _head

for _head in "${valid_head[@]}"; do
	refer=$(map_tab "$_head" raw | sed -n "s/^/^/; s/$/%/ p" | xargs | sed "s|%$| [<=>]|; s|% ^| [<=>]\|^|g; s|\^|^[0-9]+:|g") # reference
	bad_param=$(
		grep -n "" "$userconf" |
		sed -n "/^[0-9]\+:\[$_head\][ \t]*$/,/^[0-9]\+:\[.*\][ \t]*$/ { /^[0-9]\+:[^#]\+/ { /^[0-9]\+:\[.*\][ \t]*$/! p }}" |
		grep -Ev "$refer" |
		cut -f1 -d:
	)
	eval bad_param=(${bad_param})

	# Note "Bad parameter"
	local _badparam
	for _badparam in "${bad_param[@]}"; do
		sed -i "${_badparam}s|^|#|" "$userconf"
	done


	# Apply "userconffile" to "systemconffile"
	local valid_param
	local _param
	local _multi
	local _firstone

	valid_param=$(echo `sed -n "/^\[$_head\][ \t]*$/,/^\[.*\][ \t]*$/ { /^[^\[^#]/ { s|^\(.\+\) =.*$|'\1'|g p }}" "$userconf" | sort | uniq`)
		eval valid_param=(${valid_param//'/\'})

	for _param in "${valid_param[@]}"; do
		_multi=$([ "$(map_tab "$_head" uci "$_param")" == "MULTICONF" ] && echo 1 || echo 0)

		if [ "$_multi" == "1" ]; then
			_firstone=$(sed -n "/^\[$_head\][ \t]*$/,/^\[.*\][ \t]*$/ { /^$_param [<=>][ \t]*.*$/ = }" "$sysconf" | head -n1)
			# if $_param not exist?

			sed -i "$_firstone,/^\[.*\][ \t]*$/ { /$_param/ d }" "$sysconf"
			sed -i "$_firstone i $(
					sed -n "/^\[$_head\][ \t]*$/,/^\[.*\][ \t]*$/ { /^$_param [<=>][ \t]*.*$/ p }" "$userconf"\
					| sed -n "s|^|PDNSP_REPLACE_NH|g; s|$|PDNSP_REPLACE_NT|g; p"
				| xargs\
				| sed -n "s|\\\\|\\\\\\\\|g; s|^PDNSP_REPLACE_NH||; s|PDNSP_REPLACE_NT PDNSP_REPLACE_NH|\\\n|g; s|PDNSP_REPLACE_NT$||; p"
			)" "$sysconf"
		else
			sed -i "/^\[$_head\][ \t]*$/,/^\[.*\][ \t]*$/ { s~^\($_param\) \([<=>]\)[ \t]*.*$~\1 \2 $(
				sed -n "/^\[$_head\][ \t]*$/,/^\[.*\][ \t]*$/ { s~^$_param [<=>][ \t]*\(.*\)$~\1~ p }" "$userconf" | head -n1
			)~ }" "$sysconf"
		fi
	done

done

}

# update_white <urltype> <url> <outfile>
# urltype:    <git|zip>
update_white() {
	local initvar=(urltype url outfile)
	for _var in "${initvar[@]}"; do
		if [ -z "$1" ]; then >&2 echo "update_white: The <$_var> requires an argument"; return 1;
		else eval "local \$_var=\"\$1\"" && shift; fi
	done

local workdir="$(mktemp -d)"
local main='accelerated-domains.china.conf'
local google='google.china.conf'
local apple='apple.china.conf'


#echo "Downloading latest configurations..."
if   [ "$urltype" == "git" ]; then
	git clone --depth=1 "$url" "$workdir" || return 1
elif [ "$urltype" == "zip" ]; then
	curl -Lo "$workdir/main.zip" "$url" && unzip -joq "$workdir/main.zip" -d "$workdir" || return 1
	##########curl -x socks5://user:passwd@myproxy.com:8080
else
	>&2 echo "update_white: The <urltype> parameter is invalid"; return 1
fi

#echo "Generating new configurations..."
# Write latest domain data from dnsmasq-china-list project and write header
cat << EOF > "$outfile"
[Local Hosts]
## China mainland domains
## Source: $url
## Last update: `date +%Y-%m-%d`


EOF
sed "s|[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$||; s|^s|S|" "$workdir/$main" >> "$outfile"
echo -e "\n" >> "$outfile"

#echo "Cleaning up..."
rm -r "$workdir"

}

# update_routing <url> <urlv6> <outfile>
update_routing() {
	local initvar=(url urlv6 outfile)
	for _var in "${initvar[@]}"; do
		if [ -z "$1" ]; then >&2 echo "update_routing: The <$_var> requires an argument"; return 1;
		else eval "local \$_var=\"\$1\"" && shift; fi
	done

local workdir="$(mktemp -d)"
mkdir "$workdir/4"
mkdir "$workdir/6"
local ipv4rou="CN"
local ipv6rou="CN6"
local apnic='delegated-apnic-latest'
local ipdeny='cn-aggregated.zone'

local ipip='china_ip_list.txt'
local cz88='china.txt'
local coip='china.txt'
local v4list="$ipip $cz88 $coip"

local coipv6='china6.txt'
local v6list="$coipv6"

#IPv4
if   [ "${url##*.}" == "zip" ]; then
	curl -Lo "$workdir/main.zip" "$url" && unzip -joq "$workdir/main.zip" -d "$workdir/4" || return 1
	for _f in $v4list; do
		[ -f "$workdir/4/$_f" ] && cp -f "$workdir/4/$_f" "$workdir/$ipv4rou" && break
	done
elif [ "${url##*.}" == "txt" ]; then
	curl -Lo "$workdir/$ipv4rou" "$url" || return 1
elif [ "${url##*.}" == "zone" ]; then
	curl -Lo "$workdir/$ipv4rou" "$url" || return 1
elif [ "${url##*/}" == "$apnic" ]; then
	curl -Lo "$workdir/$apnic" "$url" || return 1
	cat "$workdir/$apnic" | grep ipv4 | grep CN | awk -F\| '{printf("%s/%d\n", $4, 32-log($5)/log(2))}' > "$workdir/$ipv4rou"
else
	return 1
fi

#IPv6
if   [ "${urlv6##*.}" == "zip" ]; then
	curl -Lo "$workdir/main.zip" "$urlv6" && unzip -joq "$workdir/main.zip" -d "$workdir/6" || return 1
	for _f in $v6list; do
		[ -f "$workdir/6/$_f" ] && cp -f "$workdir/6/$_f" "$workdir/$ipv6rou" && break
	done
elif [ "${urlv6##*.}" == "zone" ]; then
	curl -Lo "$workdir/$ipv6rou" "$urlv6" || return 1
	sed -Ei 's|^0{1,4}||; s|(:0{1,4})|:|g; s|:{2,}|::|' "$workdir/$ipv6rou"
elif [ "${urlv6##*/}" == "$apnic" ]; then
	if [ ! -f "$workdir/$apnic" ]; then curl -Lo "$workdir/$apnic" "$urlv6" || return 1; fi
	cat "$workdir/$apnic" | grep ipv6 | grep CN | awk -F\| '{printf("%s/%d\n", $4, $5)}' > "$workdir/$ipv6rou"
else
	return 1
fi

#echo "Generating new configurations..."
# Write latest address data from APNIC and write header.
cat << EOF > "$outfile"
[Local Routing]
## China mainland routing blocks
## Source: $url
## Sourcev6: $urlv6
## Last update: `date +%Y-%m-%d`


## IPv4
EOF
cat "$workdir/$ipv4rou" >> "$outfile"
echo -e "\n\n## IPv6" >> "$outfile"
cat "$workdir/$ipv6rou" >> "$outfile"
echo -e "\n" >> "$outfile"

#echo "Cleaning up..."
rm -r "$workdir"

}

# schedule
schedule() {
	local section=$(uci show pcap-dnsproxy.@${TYPEDSECTION2}[-1] 2>/dev/null | cut -f2 -d'.' | cut -f1 -d'=' | sed -n '1p')
	if [ -z "$section" ]; then return 1; fi
	local map="uci_$TYPEDSECTION2"

config_load $UCICFGFILE

# Defining variables for uci config
#cat <<< `map_tab "$@"` | sed -n "s/^/'/; s/$/'/ p"
local uci_list=`map_tab "$map" uci | sed -n "s/^/'/; s/$/'/ p"` # "$@"
	eval uci_list=(${uci_list//'/\'})
local uci_count=${#uci_list[@]}
# Get values of uci config
for _var in "${uci_list[@]}"; do local $_var; config_get "$_var" "$section" "$_var"; done
#config_set "$section" "$_var" "${!_var}" # Only set to environment variables


# Create schedule
local _servs='/usr/bin/pcap-dnsproxy.sh update_white_full|/usr/bin/pcap-dnsproxy.sh update_routing_full'
local _crontab='/etc/crontabs/root'
local _dln

local _cron=
local _time='* *'
local _day='*'
local _week='*'

# Get * * * * *
if   [ "$aauto" == "0" ]; then
	_dln=$(grep -En "$_servs" $_crontab 2>/dev/null | cut -f1 -d':')

	# delete cron
	if [ -n "$_dln" ]; then
		_dln=$(echo $_dln | sed -E "s|([0-9]+)|\1d;|g")
		eval "sed -i \"$_dln\" $_crontab"
	fi
	return 0

elif [ "$aauto" == "1" ]; then

	# general cron
	if   [ "$aauto_cycle" == "week" ]; then _week=${aauto_week:-3};
	elif [ "$aauto_cycle" == "month" ]; then _day=${aauto_month:-1};
	else return 1;
	fi

	_time="0 ${aauto_time:-9}"
	_cron="$_time $_day * $_week"

elif [ "$aauto" == "2" ]; then

	# crontab cron
	_cron="${aauto_cron:-0 9 * * 3}"

else return 1;
fi


	# Delete cron
	_dln=$(grep -En "$_servs" $_crontab 2>/dev/null | cut -f1 -d':')
	if [ -n "$_dln" ]; then
		_dln=$(echo $_dln | sed -E "s|([0-9]+)|\1d;|g")
		eval "sed -i \"$_dln\" $_crontab"
	fi
	# Create cron
	if [ "$aauto_white" == "1" ]; then
		[ -n "$aauto_white_src" ] && echo "$_cron /usr/bin/pcap-dnsproxy.sh update_white_full $aauto_white_src" >> $_crontab
	fi
	if [ "$aauto_route" == "1" ]; then
		echo "$_cron /usr/bin/pcap-dnsproxy.sh update_routing_full" >> $_crontab
	fi


}

uci2conf_full() {
	local TypedSection="$TYPEDSECTION"
	local ConfigFile="$CONFIGFILE"
	local UserConfig="$USERCONFIG"
	config_load $UCICFGFILE

	# Init pcap-dnsproxy Main Config file
	cp -f $RAWCONFIGFILE $CONFIGFILE 2>/dev/null
	sed -i '1 i ####\n' $CONFIGFILE

	# Apply Uci config to pcap-dnsproxy Main Config file
	for _conf in "${CONF_LIST[@]}"; do
		config_foreach uci2conf "$TypedSection" "${!_conf}" "$ConfigFile"
	done

	# Apply User config to pcap-dnsproxy Main Config file
	userconf "$UserConfig" "$ConfigFile"

}

conf2uci_full() {
	local PackageName="$UCICFGFILE"
	local TypedSection="@$TYPEDSECTION[-1]"
	local ConfigFile="$CONFIGFILE"

	# Clear ${PackageName}.${TypedSection}
	uci_remove "$PackageName" "$TypedSection"
	uci_add    "$PackageName" "$TYPEDSECTION"

	# Apply pcap-dnsproxy Main Config file to Uci config
	for _conf in "${CONF_LIST[@]}"; do
		conf2uci "$TypedSection" "${!_conf}" "$ConfigFile" "$PackageName"
	done

}

userconf_full() {
	local ConfigFile="$CONFIGFILE"
	local UserConfig="$USERCONFIG"

	# Init pcap-dnsproxy Main Config file
	cp -f $RAWCONFIGFILE $CONFIGFILE 2>/dev/null
	sed -i '1 i ####\n' $CONFIGFILE

	# Apply User config to pcap-dnsproxy Main Config file
	userconf "$UserConfig" "$ConfigFile"

}

reset_full() {

	# Reset pcap-dnsproxy Main Config file
	cp -f $RAWCONFIGFILE $CONFIGFILE 2>/dev/null
	sed -i '1 i ####\n' $CONFIGFILE

	# Reset pcap-dnsproxy Uci Config
	conf2uci_full

}

restart_service() {
	reservice 'pcap-dnsproxy' stop && sleep 2 && reservice 'pcap-dnsproxy' start

}

update_white_full() {
	local white="$WHITELIST"
	local which="$1"
	local type
	if   [ "$which" == "main" ]; then type="git";
	elif [ "$which" == "alt" ]; then type="zip";
	fi
	local main_url="$(uci get pcap-dnsproxy.@${TYPEDSECTION2}[-1].white_url 2>/dev/null)"
	local alt_url="$(uci get pcap-dnsproxy.@${TYPEDSECTION2}[-1].alt_white_url 2>/dev/null)"

	eval "local url=\"\$${which}_url\""

	if [ -n "$url" ]; then update_white "$type" "$url" $white; fi

}

update_routing_full() {
	local routing="$ROUTINGLIST"
	local v4_url="$(uci get pcap-dnsproxy.@${TYPEDSECTION2}[-1].routing_url 2>/dev/null)"
	local v6_url="$(uci get pcap-dnsproxy.@${TYPEDSECTION2}[-1].routing_v6_url 2>/dev/null)"

	if [ -n "$v4_url" -a -n "$v6_url" ]; then update_routing "$v4_url" "$v6_url" $routing; fi

}


# ================ Main ================ #

# Define Map name list
CONF_LIST=`map_def nam | sed -n "s/^/'/; s/$/'/ p"` # "$@"
	eval CONF_LIST=(${CONF_LIST//'/\'})
CONF_LIST_COUNT=${#CONF_LIST[@]}
     CONF_LIST_FIRST=${CONF_LIST[0]}
eval CONF_LIST_LAST=\${CONF_LIST[$[${CONF_LIST_COUNT}-1]]}

# Define Map name and values
for _var in "`map_def`"; do eval "${_var[@]}"; done
	#for _var in "${CONF_LIST[@]}"; do eval echo $_var=\\\"\$$_var\\\"; done





$_FUNCTION "$@"
