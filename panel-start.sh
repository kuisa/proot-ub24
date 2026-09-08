#!/bin/bash

APP=/opt/browser-panel

NODE=/opt/node22/bin/node
CHROME=/opt/chrome/chrome


echo "[BP] stopping old processes..."

pkill -f '[X]vfb :1' 2>/dev/null || true
pkill -f 'server/index.js' 2>/dev/null || true


sleep 2


echo "[BP] starting Xvfb..."


/usr/bin/Xvfb :1 \
-screen 0 1440x900x24 \
-ac \
+extension GLX \
+render \
-noreset \
>>$APP/logs/xvfb.log 2>&1 &


XVFB_PID=$!


echo $XVFB_PID > $APP/pids/xvfb.pid


sleep 2



echo "[BP] starting panel..."


cd $APP


export NODE_ENV=production

export DISPLAY=:1.0

export BROWSER_CHROME_PATH=$CHROME

export PLAYWRIGHT_CHROME_PATH=$CHROME



nohup $NODE server/index.js \
>>$APP/logs/panel.log 2>&1 &



PID=$!


echo $PID > $APP/pids/panel.pid



echo "[BP] started"

echo "Xvfb PID: $XVFB_PID"

echo "Panel PID: $PID"

echo "http://0.0.0.0:3210"