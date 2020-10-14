wget 'https://raw.githubusercontent.com/houzi-/CDN/master/kp.dat' -O files/usr/share/koolproxy/data/rules/kp.dat
wget 'https://raw.githubusercontent.com/houzi-/CDN/master/daily.txt' -O files/usr/share/koolproxy/data/rules/daily.txt
wget 'https://raw.githubusercontent.com/VeleSila/yhosts/master/hosts.txt' -O files/usr/share/koolproxy/data/rules/yhosts.txt
wget 'https://raw.githubusercontent.com/ycg31/KoolProxy/master/rules/fanboy.txt' -O files/usr/share/koolproxy/data/rules/fanboy.txt
wget 'https://raw.githubusercontent.com/ycg31/KoolProxy/master/rules/easylistchina.txt' -O files/usr/share/koolproxy/data/rules/easylistchina.txt
wget 'https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-easylist.txt' -O files/usr/share/koolproxy/data/rules/anti-ad.txt
wget 'https://gitee.com/xinggsf/Adblock-Rule/raw/main/mv.txt' -O files/usr/share/koolproxy/data/rules/mv.txt
wget 'https://raw.githubusercontent.com/firkerword/ADB/main/user.txt' -O files/usr/share/koolproxy/data/user.txt
cp files/usr/share/koolproxy/data/user.txt files/usr/share/koolproxy/data/rules/user.txt
wget 'https://raw.githubusercontent.com/firkerword/ADB/main/koolproxy_ipset.conf' -O files/usr/share/koolproxy/koolproxy_ipset.conf

wget https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt -O- | grep ^\|\|[^\*]*\^$ | sed -e 's:||:address\=\/:' -e 's:\^:/0\.0\.0\.0:' > files/usr/share/koolproxy/dnsmasq.adblock
sed -i '/youku/d' files/usr/share/koolproxy/dnsmasq.adblock
sed -i '/[1-9]\{1,3\}\.[1-9]\{1,3\}\.[1-9]\{1,3\}\.[1-9]\{1,3\}/d' files/usr/share/koolproxy/dnsmasq.adblock

