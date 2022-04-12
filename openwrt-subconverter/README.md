# openwrt-subconverter

Usage
---

1. Copy these folders to ```<openwrt-source-tree>/package```.

2. Install feeds from openwrt official package repository.
```
    ./scripts/feeds update -a
    ./scripts/feeds install -a
```
3. Use 'make menuconfig' to select subconverter package.

4. You may use 'make package/subconverter/compile V=99' to
   compile subconverter and its dependencies.
