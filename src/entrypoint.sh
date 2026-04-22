#!/bin/bash
set -e

PG_DATA="/var/lib/postgresql/data"
PG_HBA="$PG_DATA/pg_hba.conf"
PG_BIN="/usr/lib/postgresql/15/bin"

# Ensure the data directory is owned by the postgres user
# (important when the volume is freshly mounted by root)
chown -R postgres:postgres /var/lib/postgresql

# First-run: initialise the cluster and create the Joplin database/user
if [ ! -f "$PG_DATA/PG_VERSION" ]; then
    echo "[entrypoint] Initialising PostgreSQL data directory..."
    su -s /bin/bash postgres -c "$PG_BIN/initdb -D $PG_DATA --encoding=UTF8 --locale=C"

    # Allow local connections without a password during setup
    echo "host all all 127.0.0.1/32 trust" >> "$PG_HBA"

    echo "[entrypoint] Starting PostgreSQL temporarily for setup..."
    su -s /bin/bash postgres -c "$PG_BIN/pg_ctl start -D $PG_DATA -w -o '-h 127.0.0.1'"

    echo "[entrypoint] Creating Joplin database and user..."
    su -s /bin/bash postgres -c "psql -h 127.0.0.1 -c \"CREATE USER joplin WITH PASSWORD 'joplin';\""
    su -s /bin/bash postgres -c "psql -h 127.0.0.1 -c \"CREATE DATABASE joplin OWNER joplin;\""

    echo "[entrypoint] Stopping temporary PostgreSQL instance..."
    su -s /bin/bash postgres -c "$PG_BIN/pg_ctl stop -D $PG_DATA -w"

    # Replace the trust rule with a proper md5/scram rule for runtime
    sed -i '/^host all all 127.0.0.1\/32 trust/d' "$PG_HBA"
    echo "host all all 127.0.0.1/32 scram-sha-256" >> "$PG_HBA"

    echo "[entrypoint] PostgreSQL initialisation complete."
fi

export DB_CLIENT="pg"
export POSTGRES_PORT="5432"
export POSTGRES_DATABASE="joplin"
export POSTGRES_USER="joplin"
export POSTGRES_PASSWORD="joplin"
export POSTGRES_CONNECTION_STRING="postgresql://joplin:${POSTGRES_PASSWORD}@127.0.0.1:5432/joplin"

export APP_PORT="22300"
export HOME="/home/joplin"

echo "[entrypoint] Starting services via supervisord..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf