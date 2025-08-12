#!/bin/bash
set -e

echo "Setting up pg_hba.conf for LDAP authentication..."

# Copy the custom pg_hba.conf before starting server
if [ -f /docker-entrypoint-initdb.d/pg_hba.conf ]; then
  echo "Copying custom pg_hba.conf..."
  cp /docker-entrypoint-initdb.d/pg_hba.conf "$PGDATA/pg_hba.conf"
  chown postgres:postgres "$PGDATA/pg_hba.conf"
  chmod 600 "$PGDATA/pg_hba.conf"
  
  echo "LDAP pg_hba.conf configuration applied successfully"
else
  echo "Warning: pg_hba.conf not found in initdb directory"
fi