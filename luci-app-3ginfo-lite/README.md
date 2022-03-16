# luci-app-3ginfo-lite

![GitHub release (latest by date)](https://img.shields.io/github/v/release/4IceG/luci-app-3ginfo-lite?style=flat-square)
![GitHub stars](https://img.shields.io/github/stars/4IceG/luci-app-3ginfo-lite?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/4IceG/luci-app-3ginfo-lite?style=flat-square)
![GitHub All Releases](https://img.shields.io/github/downloads/4IceG/luci-app-3ginfo-lite/total)

Luci-app-3ginfo-lite is fork from https://github.com/obsy/packages/tree/master/easyconfig/addon

### <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32">
Luci-app-3ginfo-lite is a simplified version of the 3ginfo project. Works with mPCI-E/M.2 and USB 3G/LTE modems.

### <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32">
Luci-app-3ginfo-lite jest uproszczoną wersją projektu 3ginfo. Działa na modemach mPCI-E/M.2 oraz USB 3G/LTE.


``` bash
Supported devices (tested devices):
 - Quectel EM12/EM160R-GL
 - Quectel EP06-E
 - Quectel EC20/EC25
 - ZTE MF821
 - ZTE MF286
 - ZTE MF286D
 - Huawei E3372/E3276
 - Huawei E3276 HiLink
 - Huawei E5786 (mobile-wifi / HiLink)
 
Not tested devices (Not all data can be shown and scripts need to be corrected):
 - Sierra Wireless MC7710
 - Sierra Wireless EM7455
 - ASKEY WWHC050
 - BroadMobi BM806U
 - Mikrotik R11e-LTE
 - Mikrotik R11e-LTE6
 - HiLink modems (ZTE / Alcatel)

```

## <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32"> Installation / <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32"> Instalacja
``` bash
> For conventional modems.
Modem drivers are required for proper operation.
opkg install kmod-usb-serial kmod-usb-serial-option

> For Huawei HiLink modems.
opkg install wget-nossl

Dependency required.
opkg install sms-tool_2021-12-03-d38898f4-1_XXX.ipk

Install app.
opkg install luci-app-3ginfo-lite_1.0.15-20220316_all.ipk

```


### <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32"> Preview / <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32"> Podgląd

![](https://github.com/4IceG/Personal_data/blob/master/3ginfo-lite.gif?raw=true)

## <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32"> Thanks to / <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32"> Podziękowania dla
- [obsy (Cezary Jackiewicz)](https://github.com/obsy)
