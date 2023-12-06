# luci-app-cpolar

Luci support for Cpolar

[![Release Version](https://img.shields.io/github/release/probezy/luci-app-cpolar.svg)](https://github.com/probezy/luci-app-cpolar/releases/latest) [![Latest Release Download](https://img.shields.io/github/downloads/probezy/luci-app-cpolar/latest/total.svg)](https://github.com/probezy/luci-app-cpolar/releases/latest) [![Total Download](https://img.shields.io/github/downloads/probezy/luci-app-cpolar/total.svg)](https://github.com/probezy/luci-app-cpolar/releases)

## Install

### Install via OPKG (recommend)

1. Add new opkg key:

```sh
wget -O cpolar-public.key http://openwrt.cpolar.com/releases/public.key
opkg-key add cpolar-public.key
```

2. Add opkg repository from cpolar:

```sh
echo "src/gz cpolar_packages http://openwrt.cpolar.com/releases/packages/$(. /etc/openwrt_release ; echo $DISTRIB_ARCH)" \
  >> /etc/opkg/customfeeds.conf
opkg update
```

3. Install package:

```sh
opkg install luci-app-cpolar
opkg install luci-i18n-cpolar-zh-cn
```

We also support HTTPS protocol.

4. Upgrade package:

```sh
opkg update
opkg upgrade luci-app-cpolar
opkg upgrade luci-i18n-cpolar-zh-cn
```

### Manual install

1. Download ipk files from [release](https://github.com/probezy/openwrt-cpolar/releases) page

2. Upload files to your router

3. Install package with opkg:

```sh
opkg install luci-app-cpolar_*.ipk
```

Depends:

- jshn
- luci-lib-jsonc

For translations, please install ```luci-i18n-cpolar-*```.

## Configure

1. Download Cpolar ipk release [link](https://github.com/probezy/openwrt-cpolar/releases).

2. install the ipk file.

3. Config Cpolar file path in LuCI page.

4. Add your Tunnel rules.

5. Enable the service via LuCI.

## Build

```shell
git clone https://github.com/probezy/luci-app-cpolar.git

mv  luci-app-cpolar package/
```

