#!/bin/bash
svn co https://github.com/kenzok8/openwrt-packages/trunk ./
rm -rf .svn
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw ./
rm -rf .svn
svn co https://github.com/cnzd/luci-app-koolproxyR/trunk ./luci-app-koolproxyR
rm -rf .svn
svn co https://github.com/xiaorouji/openwrt-package/trunk ./
rm README.md .gitattributes .gitignore
exit 0
