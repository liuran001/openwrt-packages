#!/bin/bash
rename README.md README1.md
svn co https://github.com/kenzok8/openwrt-packages/trunk ./
rm -rf .svn
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw ./
rm -rf .svn
svn co https://github.com/cnzd/luci-app-koolproxyR/trunk ./luci-app-koolproxyR
rm -rf .svn
rm README.md
rename README1.md README.md
exit 0