FROM joplin/server:3.6.1

LABEL org.opencontainers.image.source=https://github.com/lonode/joplin-server-standalone
LABEL org.opencontainers.image.description="Standalone Joplin Server with embedded PostgreSQL"
LABEL org.opencontainers.image.licenses=AGPL-3.0

# Switch to root to install system packages
USER root

RUN apt-get update && apt-get install -y \
    postgresql postgresql-client \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

COPY src/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22300
ENTRYPOINT ["/entrypoint.sh"]