# LDAP Server Demo

A minimal LDAP server solution with PostgreSQL, OpenLDAP, and phpLDAPadmin using Docker Compose.

## Services

- **PostgreSQL**: Database server on port 5432
- **OpenLDAP**: LDAP server on ports 389 (LDAP) and 636 (LDAPS)
- **phpLDAPadmin**: Web interface on port 8080

## Quick Start

1. Start all services:
   ```bash
   docker-compose up -d
   ```

2. Access phpLDAPadmin at http://localhost:8080
   - Login DN: `cn=admin,dc=example,dc=com`
   - Password: `admin123`

3. Connect to PostgreSQL:
   ```bash
   psql -h localhost -U ldapuser -d ldapdb
   ```
   Password: `ldappass`

## Configuration

Edit `.env` file to customize:
- Database credentials
- LDAP domain and organization
- Admin passwords

## Default LDAP Structure

- Base DN: `dc=example,dc=com`
- Users: `ou=people,dc=example,dc=com`
- Groups: `ou=groups,dc=example,dc=com`
- Sample user: `john.doe` (password needs to be set via phpLDAPadmin)

## Stopping Services

```bash
docker-compose down
```

To remove all data:
```bash
docker-compose down -v
```