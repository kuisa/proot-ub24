Ubuntu 24.04部署proot：

mkdir MyWorlds && cd MyWorlds && curl -o toor.sh https://raw.githubusercontent.com/kuisa/proot-ub24/main/toor.sh && chmod +x toor.sh && bash toor.sh


依次安装:(在已经进入proot的环境下)

init(初始化)：

echo "127.0.0.1 localhost" > /etc/hosts && apt update && apt install curl wget nano sudo bash nginx -y

安装并修复web：

curl -o /root/install-web.sh https://raw.githubusercontent.com/kuisa/proot-ub24/main/install-web.sh && chmod +x /root/install-web.sh && bash /root/install-web.sh

依赖：

curl -o /root/stack.sh https://raw.githubusercontent.com/kuisa/proot-ub24/main/stack.sh && chmod +x /root/stack.sh && bash /root/stack.sh

面板：

curl -o /root/bp.sh https://raw.githubusercontent.com/kuisa/proot-ub24/main/bp.sh && chmod +x /root/bp.sh && bash /root/bp.sh

开机启动文件：

curl -o /root/panel-start.sh https://raw.githubusercontent.com/kuisa/proot-ub24/main/panel-start.sh && chmod +x /root/panel-start.sh && bash /root/panel-start.sh

ff安装：

wget -O /tmp/ff155.tar.xz "https://github.com/LoseNine/ruyipage/releases/download/v1.2.66/firefox-155.0.en-US.linux-x86_64.tar.xz" && rm -rf /opt/ruyipage-firefox && mkdir -p /tmp/ff155_ext && tar -xf /tmp/ff155.tar.xz -C /tmp/ff155_ext && mv /tmp/ff155_ext/firefox /opt/ruyipage-firefox && chmod -R 777 /opt/ruyipage-firefox && rm -rf /tmp/ff155.tar.xz /tmp/ff155_ext

ruyipage安装：

python3 -m pip install ruyipage --break-system-packages

面板及浏览器修复(需要在面板及浏览器安装完毕后运行,修复后需要运行bash /root/panel-start.sh重启面板)：

curl -o /root/fix_browser.sh https://raw.githubusercontent.com/kuisa/proot-ub24/main/fix_browser.sh && chmod +x /root/fix_browser.sh && (pkill -f 'node server/index.js' 2>/dev/null || true); && bash /root/fix_browser.sh

其它(cloudflared + webttyd)(可选)：

curl -L -o /usr/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && chmod +x /usr/bin/cloudflared && mkdir /var/www/html/ssh && chmod 777 /var/www/html/ssh && cd /var/www/html/ssh && wget -O ttyd https://netjett-de.kof95zip.pp.ua/ttyd.x86_64 && chmod +x ttyd
