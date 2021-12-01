# NueXini_Packages
### 如何使用？ / How to use?
```bash
#cd lede
cd openwrt
sed -i '$a src-git NueXini_Packages https://github.com/NueXini/NueXini_Packages.git' feeds.conf.default
./scripts/feeds update -a && ./scripts/feeds install -a
```

# 更新日志
【2021/11/30】luci-app-godproxy 更名为 luci-app-ikoolproxy
