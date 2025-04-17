#!/bin/sh
set -e

# 从环境变量获取 Cloudflare Token
CF_TOKEN=${CF_TOKEN:-""}

# 启动 cloudflared（如果提供了 Token）
if [ -n "$CF_TOKEN" ]; then
    echo "Starting cloudflared with provided token..."
    /usr/local/bin/cloudflared --no-autoupdate tunnel run --protocol http2 --token "$CF_TOKEN" &
    CLOUDFLARED_PID=$!
    echo "cloudflared started with PID $CLOUDFLARED_PID"
else
    echo "Warning: CF_TOKEN is not set, skipping cloudflared"
fi

# 首次启动时尝试恢复备份（以 node 用户运行）
echo "Checking for backup to restore on first start..."
/backup_restore.sh restore

# 启动 cron 服务以支持定时备份
echo "Starting cron service for scheduled backups..."
cron -f &
CRON_PID=$!
echo "cron started with PID $CRON_PID (may fail silently if permissions are insufficient)"

# 执行原始的 CMD 命令（即启动 node 应用）
echo "Starting main application..."
exec "$@"
