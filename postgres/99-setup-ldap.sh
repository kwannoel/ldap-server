#!/bin/bash
set -e

# Copy custom pg_hba.conf
cp /docker-entrypoint-initdb.d/pg_hba.conf $PGDATA/pg_hba.conf
chown postgres:postgres $PGDATA/pg_hba.conf
chmod 600 $PGDATA/pg_hba.conf

echo "LDAP pg_hba.conf configuration applied"