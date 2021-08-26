## Compile

在OpenWrt SDK中的package目录下执行如下命令：

`$ git clone https://github.com/KyleRicardo/luci-app-airwhu.git`

在luci-app-airwhu/tools/po2lmo下打开终端，运行如下命令：

`$ make && sudo make install`

然后在OpenWrt SDK根目录下执行如下命令：

`$ make package/luci-app-airwhu/compile V=s`

编译成功后，找到生成的ipk文件拷贝到路由器中，用opkg安装就可以使用了。

## Install

代码中只包含Lua和Bash脚本，所以不受限于平台，编译后的文件可以在任何平台安装：

`$ opkg install luci-app-airwhu_1.0-1_all.ipk`

该luci界面依赖MentoHUST以及kmod-ipt-nat6这两个ipk包。
