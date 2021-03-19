#!/bin/sh
# Copyright 2020-2021 Rafał Wabik (IceG) - From eko.one.pl forum
# Licensed to the GNU General Public License v3.0.

work=false
for port in /dev/ttyUSB*
do
    [[ -e $port ]] || continue
    gcom -d $port info &> /tmp/testusb
    testUSB=`cat /tmp/testusb | grep "Error\|Can't"`
    if [ -z "$testUSB" ]; then 
        work=$port
        break
    fi
done
rm -rf /tmp/testusb

if [ $work != false ]; then
uci set 3ginfo.device=$work
uci commit 3ginfo
fi
