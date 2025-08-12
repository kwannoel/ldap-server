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
- Sample user: `john.doe`, password: `abc` (password needs to be set via phpLDAPadmin)

## User Stories

### Creating a New User

**As an administrator, I want to create a new user in the LDAP directory so that they can authenticate and access resources.**

**Steps:**
1. Access phpLDAPadmin at http://localhost:8080
2. Login with admin credentials (`cn=admin,dc=example,dc=com` / `admin123`)
3. Navigate to `ou=people,dc=example,dc=com`
4. Click "Create a child entry"
5. Select "Generic: User Account" template
6. Fill in required fields:
   - **First name**: User's given name
   - **Last name**: User's surname
   - **Common Name**: Full display name
   - **User ID**: Username for login (e.g., `jane.smith`)
   - **Email**: User's email address
   - **Password**: Set user's initial password
7. Set POSIX account details:
   - **UID Number**: Unique user ID (e.g., 1002)
   - **GID Number**: Primary group ID (e.g., 1001 for "users" group)
   - **Home Directory**: `/home/username`
   - **Login Shell**: `/bin/bash`
8. Click "Create Object" to save

**Acceptance Criteria:**
- User can be found in directory search
- User can authenticate with their credentials
- User appears in the correct organizational unit
- User has proper POSIX attributes for system access

**Verification:**
```bash
# Search for the new user
docker exec ldap-server ldapsearch -x -H ldap://localhost -b "ou=people,dc=example,dc=com" -D "cn=admin,dc=example,dc=com" -w admin123 "(uid=jane.smith)"

# Test user authentication
docker exec ldap-server ldapwhoami -x -H ldap://localhost -D "uid=jane.smith,ou=people,dc=example,dc=com" -w userpassword
```

**PostgreSQL Integration (Optional):**

To enable LDAP authentication for PostgreSQL:

1. **Configure PostgreSQL for LDAP auth** - Add to `pg_hba.conf`:
   ```
   host    all    all    0.0.0.0/0    ldap ldapserver=openldap ldapport=389 ldapbinddn="cn=admin,dc=example,dc=com" ldapbindpasswd=admin123 ldapsearchattribute=uid ldapbasedn="ou=people,dc=example,dc=com"
   ```

2. **Create PostgreSQL user** (matches LDAP uid):
   ```bash
   # Connect as postgres admin
   docker exec -it ldap-postgres psql -U ldapuser -d ldapdb
   
   # Create user matching LDAP uid
   CREATE USER "jane.smith";
   GRANT CONNECT ON DATABASE ldapdb TO "jane.smith";
   GRANT USAGE ON SCHEMA public TO "jane.smith";
   ```

3. **Test LDAP authentication to PostgreSQL**:
   ```bash
   # User authenticates via LDAP, connects to PostgreSQL
   psql -h localhost -U jane.smith -d ldapdb
   # Enter LDAP password when prompted
   ```

**Note**: This requires mounting a custom `pg_hba.conf` in the docker-compose configuration.

## Stopping Services

```bash
docker-compose down
```

## Cleaning Data

To completely reset and clean all persistent data:

```bash
# Stop all services
docker-compose down

# Remove all volumes manually (recommended for complete cleanup)
docker volume rm ldap-server_postgres_data ldap-server_ldap_data ldap-server_ldap_config

# Restart with fresh data
docker-compose up -d
```

Alternative one-liner (removes volumes automatically):
```bash
docker-compose down -v && docker-compose up -d
```

**Note**: The manual volume removal method ensures complete cleanup, especially useful when troubleshooting persistent configuration issues.