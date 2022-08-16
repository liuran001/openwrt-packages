# luci-app-modeminfo
3G/LTE dongle information for OpenWrt LuCi


luci-app-modeminfo is fork from https://github.com/IceG2020/luci-app-3ginfo

Supported devices:

 - Quectel EC200T/EC21/EC25/EP06/EM12

 - SimCom SIM7600E-H

 - Huawei E3372 (LTE)/ME909

 - Sierra Wireless EM7455

 - HP LT4220

 - Dell DW5821e
 
 - MikroTik R11e-LTE/R11e-LTE6 (temporary dropped)

 - Fibocom NL668/NL678/L850/L860



Compiled OpenWrt 18.06-19.07 version [luci-app-modeminfo_0.2.3-1_all.ipk](http://openwrt.132lan.ru/packages/packages-19.07/luci/luci-app-modeminfo_0.2.3-1_all.ipk)

<details>
<summary>Compiled OpenWrt 21.02 version:</summary>

luci-app-modeminfo - LuCI web interface

modeminfo - common files

modeminfo-qmi - Qualcomm MSM Interface support

modeminfo-serial-quectel - Quectel modems support

modeminfo-serial-telit - Telit LN940 (HP LT4220) modem support

modeminfo-serial-huawei - Huawei ME909/E3372(stick mode, LTE only) modems support

modeminfo-serial-sierra - Sierra EM7455 modem support

modeminfo-serial-simcom - SimCOM modems support

modeminfo-serial-dell - Dell DW5821e modem support

modeminfo-serial-fibocom - Fibocom LN668/NL678 modems support

modeminfo-serial-xmm - Fibocom L850/L860 modems support
</details>

<details>
   <summary>How install precompiled packages</summary>
   Add repositories for your Router in /etc/opkg/customfeeds.conf
   
   For Openwrt 19th branch:
   
   ```
   src/gz 132lan_luci http://openwrt.132lan.ru/packages/packages-19.07/luci
   ```
   
   For OpenWrt 21th branch:
   
   ```
   src/gz 132lan_luci http://openwrt.132lan.ru/packages/packages-21.02/luci
   src/gz 132lan_all http://openwrt.132lan.ru/packages/packages-21.02/all
   src/gz 132lan_app http://openwrt.132lan.ru/packages/packages-21.02/<arch>/packages
   ```
   
   Comment out line in /etc/opkg.conf
   
   ```
   #option check_signature
   ```
   
   <details>
      <summary>WARNING</summary>
      
      OpenWrt 21th version modeminfo-serial-* packages have dependies: atinout. Please check compiled package for your platform.
      
      Current build <arch> are:
      
      - mipsel_24kc
      
      - arm_cortex-a7_neon-vfpv4
      
      - aarch64_cortex-a53
      
   </details>
   
   
  Update packages list and install packages e.g example:
  
  ```
  opkg update
  ```
  
  OpenWrt 19th:
  
  ```
  opkg install luci-app-modeminfo
  ```
  
  OpenWrt 21th:
  ```
  opkg install luci-app-modeminfo modeminfo-qmi
  ```
  
</details>
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

