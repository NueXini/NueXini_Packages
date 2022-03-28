## Luci-app-sms-tool

![GitHub release (latest by date)](https://img.shields.io/github/v/release/4IceG/luci-app-sms-tool?style=flat-square)
![GitHub stars](https://img.shields.io/github/stars/4IceG/luci-app-sms-tool?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/4IceG/luci-app-sms-tool?style=flat-square)
![GitHub All Releases](https://img.shields.io/github/downloads/4IceG/luci-app-sms-tool/total)

### <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32">
Luci-app-sms-tool is a mini gui for handling messages via sms_tool application/project https://eko.one.pl/?p=openwrt-sms_tool
Works with mPCI-E and USB 3G/LTE modems. Don't work with HiLink/RNDIS modems.

### <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32">
Luci-app-sms-tool jest prostym interfejsem użytkownika dla projetu/aplikacji sms_tool https://eko.one.pl/?p=openwrt-sms_tool. Aplikacji umożliwia obsługę wiadomości sms i kodów ussd. Działa na modemach mPCI-E oraz USB 3G/LTE. Nie działa z modemami HiLink/RNDIS.

### <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32"> Preview and quick configuration (modem Quectel EM160R-GL) / <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32"> Podgląd oraz szybka konfiguracja (modem Quectel EM160R-GL)

![](https://github.com/4IceG/Personal_data/blob/master/zrzuty/193/193gif.gif?raw=true)

## <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32"> Installation / <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32"> Instalacja
``` bash
#Modem drivers are required for proper operation.
opkg install kmod-usb-serial kmod-usb-serial-option luci-compat

#The sms-tool package is not available in the OpenWrt core repository. 
#Sms-tool is only available in the eko.one.pl forum repository. 
#If you do not have an image from forum eko.one.pl you have to compile the package manually.

#For images from the eko.one.pl forum we proceed:
opkg update
opkg install sms-tool

wget https://github.com/4IceG/luci-app-sms-tool/releases/download/1.9.4-20220325/luci-app-sms-tool_1.9.4-20220325_all.ipk -O /tmp/luci-app-sms-tool_1.9.4-20220325_all.ipk
opkg install /tmp/luci-app-sms-tool_1.9.4-20220325_all.ipk
```

## <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32"> Screenshots / <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32"> Zrzuty ekranu

- "Received Messages" window / Okno odebranych wiadomości:

![](https://github.com/4IceG/Personal_data/blob/master/zrzuty/193/193.1.png?raw=true)

- "Sending Message" window / Okno wysyłania wiadomości:

![](https://github.com/4IceG/Personal_data/blob/master/zrzuty/193/193.2.png?raw=true)

- "USSD Codes" window / Okno kodów USSD:

![](https://github.com/4IceG/Personal_data/blob/master/zrzuty/193/193.3.png?raw=true)

- "AT Commands" window / Okno poleceń AT:

![](https://github.com/4IceG/Personal_data/blob/master/zrzuty/193/193.4.png?raw=true)

- "Configuration" window / Okno konfiguracji:

![](https://github.com/4IceG/Personal_data/blob/master/zrzuty/193/193.5a.png?raw=true)
![](https://github.com/4IceG/Personal_data/blob/master/zrzuty/193/193.5b.png?raw=true)
![](https://github.com/4IceG/Personal_data/blob/master/zrzuty/193/193.5c.png?raw=true)
![](https://github.com/4IceG/Personal_data/blob/master/zrzuty/193/193.5d.png?raw=true)

## <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_United_Kingdom.png" height="32"> Thanks to / <img src="https://raw.githubusercontent.com/4IceG/Personal_data/master/dooffy_design_icons_EU_flags_Poland.png" height="32"> Podziękowania dla
- [obsy (Cezary Jackiewicz)](https://github.com/obsy)
- [eko.one.pl](https://eko.one.pl/forum/viewtopic.php?id=20096)
