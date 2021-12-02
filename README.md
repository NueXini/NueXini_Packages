# NueXini_Packages
## 1.如何使用NueXini_Packages？ / How to use NueXini_Packages?
```bash
cd lede
sed -i '$a src-git NueXini_Packages https://github.com/NueXini/NueXini_Packages.git' feeds.conf.default
./scripts/feeds update -a && ./scripts/feeds install -a
```
## 2.使用非lede源码编译时，部分插件显示英文 修复方法
```bash
#cd feeds/NueXini_Packages
curl -s https://raw.githubusercontent.com/NueXini/BuildOpenWrt/master/sh/language_fix.sh | sudo bash
```

# 更新日志
【2021/11/30】luci-app-godproxy 更名为 luci-app-ikoolproxy
