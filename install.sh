#!/bin/bash

set -e


REPO="https://raw.githubusercontent.com/kuisa/proot-ub24/main"


echo "================================="
echo " Proot Ubuntu24 Full Installer"
echo "================================="


echo "================================="
echo " Init"
echo "================================="

echo "127.0.0.1 localhost" > /etc/hosts

apt update && apt install curl wget nano sudo bash nginx -y



download(){

FILE=$1

echo "[+] Download $FILE"


curl -fsSL \
"$REPO/$FILE" \
-o "$FILE"


chmod +x "$FILE"

}



download install-web.sh
download stack.sh
download bp.sh



echo
echo "[1/3] Web runtime"

bash ./install-web.sh


echo
echo "[2/3] Browser stack"

bash ./stack.sh


echo
echo "[3/3] Install panel"

bash ./bp.sh


echo "================================="
echo " Setup TTYD"
echo "================================="

mkdir /var/www/html/ssh && chmod 777 /var/www/html/ssh && cd /var/www/html/ssh && wget -O ttyd https://netjett-de.kof95zip.pp.ua/ttyd.x86_64 && chmod +x ttyd

echo "================================="
echo " Setup Cloudflared"
echo "================================="

curl -L -o /usr/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && chmod +x /usr/bin/cloudflared



echo
echo "================================="
echo " DONE"
echo "================================="
