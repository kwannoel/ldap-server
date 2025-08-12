#!/bin/bash
set -e

# Copy custom pg_hba.conf and reload PostgreSQL
cp /tmp/pg_hba.conf /var/lib/postgresql/data/pg_hba.conf
chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf
chmod 600 /var/lib/postgresql/data/pg_hba.conf

# Signal PostgreSQL to reload configuration
pg_ctl reload -D /var/lib/postgresql/data