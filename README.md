一键运行:(在已经进入proot的环境下)

apt update && apt install curl -y && curl -o install.sh https://raw.githubusercontent.com/kuisa/proot-ub24/main/install.sh && chmod +x install.sh && bash install.sh

上面脚本会安装：bp面板+脚本依赖+php+nginx+cloudflared+webttyd
