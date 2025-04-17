# 基于原始镜像
FROM ghcr.io/fev125/dstatus:latest AS app

# 切换到 root 用户以执行权限修改和安装
USER root

# 安装 cloudflared
COPY --from=cloudflare/cloudflared:latest /usr/local/bin/cloudflared /usr/local/bin/cloudflared

# 安装 awscli（用于R2交互）和 cron（用于定时备份）
RUN apt-get update && apt-get install -y \
    awscli \
    cron \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 调整 cron 相关目录权限，使非 root 用户可以运行
RUN mkdir -p /var/run/cron && chmod 777 /var/run/cron /var/run

# 复制入口脚本和备份脚本
COPY entrypoint.sh /entrypoint.sh
COPY backup_restore.sh /backup_restore.sh

# 确保脚本具有执行权限
RUN chmod +x /entrypoint.sh /backup_restore.sh

# 添加定时任务（每天凌晨执行备份）
RUN echo "0 2,14 * * * /backup_restore.sh backup >> /var/log/backup.log 2>&1" | crontab -

# 切换回原始用户 node 以确保运行时安全
USER node

# 设置入口点为自定义脚本
ENTRYPOINT ["/entrypoint.sh"]

# 保持原始 CMD，确保 node 应用作为主进程
CMD ["node", "nekonekostatus.js"]
