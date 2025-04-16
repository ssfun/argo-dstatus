FROM ghcr.io/fev125/dstatus:latest AS app

COPY --from=cloudflare/cloudflared:latest /usr/local/bin/cloudflared /usr/local/bin/cloudflared

COPY . .

ENTRYPOINT ["/entrypoint.sh"]
