#更换国内源
cp $PREFIX/etc/apt/sources.list $PREFIX/etc/apt/sources.list.bak
echo "# The termux repository mirror from TUNA:
deb http://mirrors.tuna.tsinghua.edu.cn/termux stable main" >$PREFIX/etc/apt/sources.list

#trojan
pkg install git clang cmake boost-dev openssl-dev -y
git clone https://github.com/trojan-gfw/trojan
cd trojan
sed -i '/if(WIN32)/i\target_link_libraries(trojan atomic)' CMakeLists.txt
cmake -DCMAKE_INSTALL_PREFIX=/data/data/com.termux/files/usr -DENABLE_MYSQL=OFF .
make install

#trojan配置
cp -f /data/data/com.termux/files/usr/share/doc/trojan/examples/client.json-example /data/data/com.termux/files/usr/etc/trojan/config.json
read -p "输入trojan服务器域名:" domain && read -p "输入trojan密码:" password && sed -i "s/password1/$password/g;s/example.com/$domain/g" /data/data/com.termux/files/usr/etc/trojan/config.json

#clash
pkg install golang wget -y
cd ~
go get -u -ldflags "-s -w" github.com/Dreamacro/clash && chmod +x go/bin/clash && mv go/bin/clash /data/data/com.termux/files/usr/bin/

#clash配置
mkdir ~/.config/clash ; wget https://raw.githubusercontent.com/ConnersHua/Profiles/master/Clash/Global.yml -O ~/.config/clash/config.yml
sed -i '/^# HTTP 代理端口/,/# 规则$/d ' ~/.config/clash/config.yml
sed -i '1iport: 1090\
allow-lan: false\
mode: Rule\
log-level: silent\
external-controller: 127.0.0.1:9090\
Proxy:\
- { name: "trojan", type: socks5, server: 127.0.0.1, port: 1080 }\
Proxy Group:\
- { name: "PROXY", type: select, proxies: ["trojan"] }\
# 白名单模式 PROXY，黑名单模式 DIRECT\
- { name: "FINAL", type: select, proxies: ["PROXY", "DIRECT"] }\
- { name: "MEDIA", type: select, proxies: ["PROXY"] }\
- { name: "HIJACKING", type: select, proxies: ["DIRECT", "REJECT"] }\
' ~/.config/clash/config.yml

#开机启动
mkdir -p ~/.termux/boot/
echo "termux-wake-lock
trojan & calsh &" >> ~/.termux/boot/trojan

#清理
#pkg uninstall clang cmake boost-dev golang -y
#apt autoremove -y
