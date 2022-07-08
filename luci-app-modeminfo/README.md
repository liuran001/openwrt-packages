# luci-app-modeminfo
3G/LTE dongle information for OpenWrt LuCi


luci-app-modeminfo is fork from https://github.com/IceG2020/luci-app-3ginfo

Supported devices:

 - Quectel EC21/EC25/EP06/EM12

 - SimCom SIM7600E-H

 - Huawei E3372 (LTE)/ME909

 - Sierra Wireless EM7455

 - HP LT4220

 - Dell DW5821e
 
 - MikroTik R11e-LTE/R11e-LTE6 (temporary dropped)

 - Fibocom NL668/NL678/L850/L860



Compiled OpenWrt 18.06-19.07 version [luci-app-modeminfo_0.2.3-1_all.ipk](http://openwrt.132lan.ru/packages/packages-19.07/luci/luci-app-modeminfo_0.2.3-1_all.ipk)

Compiled OpenWrt 21.02 version:

[luci-app-modeminfo_0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/luci/luci-app-modeminfo_0.3.0-1_all.ipk) - LuCI web interface

[modeminfo-0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/all/modeminfo_0.3.0-1_all.ipk) - common files

[modeminfo-qmi-0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/all/modeminfo-qmi_0.3.0-1_all.ipk) - Qualcomm MSM Interface support

[modeminfo-serial-quectel-0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/all/modeminfo-serial-quectel_0.3.0-1_all.ipk) - Quectel modems support

[modeminfo-serial-telit-0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/all/modeminfo-serial-telit_0.3.0-1_all.ipk) - Telit LN940 (HP LT4220) modem support

[modeminfo-serial-huawei-0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/all/modeminfo-serial-huawei_0.3.0-1_all.ipk) - Huawei ME909/E3372(stick mode, LTE only) modems support

[modeminfo-serial-sierra-0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/all/modeminfo-serial-sierra_0.3.0-1_all.ipk) - Sierra EM7455 modem support

[modeminfo-serial-simcom-0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/all/modeminfo-serial-simcom_0.3.0-1_all.ipk) - SimCOM modems support

[modeminfo-serial-dell-0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/all/modeminfo-serial-dell_0.3.0-1_all.ipk) - Dell DW5821e modem support

[modeminfo-serial-fibocom-0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/all/modeminfo-serial-fibocom_0.3.0-1_all.ipk) - Fibocom LN668/NL678 modems support

[modeminfo-serial-xmm-0.3.0-1_all.ipk](http://openwrt.132lan.ru/packages/packages-21.02/all/modeminfo-serial-xmm_0.3.0-1_all.ipk) - Fibocom L850/L860 modems support



Сompiled old versions https://inf.labz.ru/repo/


# How-To compile

add git repos in feeds.conf.default OpenWrt SDK

```
src-git atinout https://github.com/koshev-msk/luci-app-atinout.git^38a7298736e05b6cf3b5f61862e8d534a690c972
```

```
src-git modeminfo https://github.com/koshev-msk/luci-app-modeminfo.git
```

update feeds and compile package. E.g

```
./scripts/feeds update -a && ./scripts feeds install -a
make -j$((`nproc`+1)) package/feeds/modeminfo/luci-app-modeminfo/compile
```


<details>
   <summary>Screenshots</summary>

   ![](https://raw.githubusercontent.com/koshev-msk/luci-app-modeminfo/master/screenshots/modeminfo-network.png)
	
   ![](https://raw.githubusercontent.com/koshev-msk/luci-app-modeminfo/master/screenshots/modeminfo-hardware.png)

   ![](https://raw.githubusercontent.com/koshev-msk/luci-app-modeminfo/master/screenshots/modeminfo-setup.png)

</details>

