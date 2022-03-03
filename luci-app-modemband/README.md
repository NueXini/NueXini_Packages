# luci-app-modemband

![GitHub release (latest by date)](https://img.shields.io/github/v/release/4IceG/luci-app-modemband?style=flat-square)
![GitHub stars](https://img.shields.io/github/stars/4IceG/luci-app-modemband?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/4IceG/luci-app-modemband?style=flat-square)
![GitHub All Releases](https://img.shields.io/github/downloads/4IceG/luci-app-modemband/total)

Luci-app-modemband is a My GUI for https://eko.one.pl/?p=openwrt-modemband. A program to set LTE bands for selected 4G modems.

Supported devices:
- BroadMobi BM806U
- Huawei E3272/E3276/E3372 in serial mode
- Quectel EC20
- Quectel EC25
- Quectel EG06-E
- Quectel EM12-G
- Quectel EM160R-GL
- Quectel EP06-E
- Quectel RG502Q-EA
- ZTE MF286 (router)
- ZTE MF286A (router)
- ZTE MF286D (router)
- ZTE MF286R (router)

``` bash
#Modem drivers are required for proper operation.
kmod-usb-serial kmod-usb-serial-option

#+DEPENDS:
sms-tool_2021-12-03-d38898f4-1 modemband_20220220

```

### <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32"> Preview / <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32"> Podgląd

![](https://github.com/4IceG/Personal_data/blob/master/modembandgui.gif?raw=true)


## <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32"> Thanks to / <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32"> Podziękowania dla
- [obsy (Cezary Jackiewicz)](https://github.com/obsy)
