# Node.js 26
FROM node:26-trixie-slim AS node

# OS
FROM debian:13-slim

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Jakarta

# Deps
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        nginx \
        supervisor \
        tzdata \
    && ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Node.js + npm
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# App user
RUN groupadd -g 1000 www \
    && useradd -u 1000 -m -s /bin/bash -g www www

# App
WORKDIR /app
COPY --chown=www:www app/ /app/
RUN chmod +x /app/server-linux

# Config
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/log/supervisor

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]