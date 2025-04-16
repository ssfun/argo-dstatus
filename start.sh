#!/bin/sh

CF_TOKEN=${CF_TOKEN:-""}

echo "Starting dstatus app..."
node nekonekostatus.js &
sleep 3

# 启动 cloudflared
if [ -n "$CF_TOKEN" ]; then
    echo "Starting cloudflared..."
    cloudflared --no-autoupdate tunnel run --protocol http2 --token "$CF_TOKEN" &
else
    echo "Warning: CF_TOKEN is not set, skipping cloudflared"
fi

# 等待所有后台进程
wait
