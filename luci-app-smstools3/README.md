# luci-app-smstools3

Web UI smstools3 for OpenWrt LuCI.
How-to compile:
```
cd feeds/luci/applications/
git clone https://github.com/koshev-msk/luci-app-smstools3.git
cd ../../..
./scripts/feeds update -a; ./scripts/feeds install -a
make -j $(($(nproc)+1)) package/feeds/luci/luci-app-smstools3/compile
```

Note: If you use this app with modemmanager, please move or remove /etc/hotplug.d/tty/25-modemmanager-tty

<details>
   <summary>Screenshots</summary>
   
   ![](https://raw.githubusercontent.com/koshev-msk/luci-app-smstools3/master/screenshots/incoming.png)
   
   ![](https://raw.githubusercontent.com/koshev-msk/luci-app-smstools3/master/screenshots/outcoming.png)
   
   ![](https://raw.githubusercontent.com/koshev-msk/luci-app-smstools3/master/screenshots/push.png)
   
   ![](https://raw.githubusercontent.com/koshev-msk/luci-app-smstools3/master/screenshots/setup.png)
   
</details>
