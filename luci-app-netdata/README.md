### 访问数：[![](https://visitor-badge.glitch.me/badge?page_id=sirpdboy-visitor-badge)] [![](https://img.shields.io/badge/TG群-点击加入-FFFFFF.svg)](https://t.me/joinchat/AAAAAEpRF88NfOK5vBXGBQ)

![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/说明1.jpg)

[luci-app-netdata可控制的实时监控 ](https://github.com/sirpdboy/luci-app-netdata)
======================

git clone https://github.com/sirpdboy/luci-app-netdata.git

cd openwrt

echo "src-git cups https://github.com/sirpdboy/luci-app-netdata" >> feeds.conf.default

./scripts/feeds update -a

./scripts/feeds install -a


make menuconfig

LuCI  --->

	1. Collections  --->
	
		<*> luci
		
	3. Applications  --->
	
		<*> luci-app-netdata.........................LuCI support for Netdata

make package/luci-app-netdata/compile V=s


## 界面
![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/netdata1.jpg)

![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/netdata2.jpg)

![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/说明2.jpg)

# My other project

网络速度测试 ：https://github.com/sirpdboy/NetSpeedTest

定时设置插件 : https://github.com/sirpdboy/luci-app-autotimeset

关机功能插件 : https://github.com/sirpdboy/luci-app-poweroffdevice

opentopd主题 : https://github.com/sirpdboy/luci-theme-opentopd

opentoks 主题: https://github.com/sirpdboy/luci-theme-opentoks [仿KOOLSAHRE主题]

btmob 主题: https://github.com/sirpdboy/luci-theme-btmob

系统高级设置 : https://github.com/sirpdboy/luci-app-advanced

ddns-go动态域名: https://github.com/sirpdboy/luci-app-ddns-go

## 捐助

![screenshots](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/说明3.jpg)

|     <img src="https://img.shields.io/badge/-支付宝-F5F5F5.svg" href="#赞助支持本项目-" height="25" alt="图飞了������"/>  |  <img src="https://img.shields.io/badge/-微信-F5F5F5.svg" height="25" alt="图飞了������" href="#赞助支持本项目-"/>  | 
| :-----------------: | :-------------: |
|![xm1](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/支付宝.png) | ![xm1](https://raw.githubusercontent.com/sirpdboy/openwrt/master/doc/微信.png) |

<a href="#readme">
    <img src="https://img.shields.io/badge/-返回顶部-orange.svg" alt="图飞了������" title="返回顶部" align="right"/>
</a>
