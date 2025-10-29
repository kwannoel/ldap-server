# LDAP Server Demo

A minimal LDAP server solution with PostgreSQL, OpenLDAP, and phpLDAPadmin using Docker Compose.

## Services

- **PostgreSQL**: Database server on port 5432
- **OpenLDAP**: LDAP server on ports 389 (LDAP) and 636 (LDAPS)
- **phpLDAPadmin**: Web interface on port 8080

## Quick Start

1. Init certs:
   ```
   cd certs
   bash init-certs.sh
   ```

2. Start all services:
   ```bash
   docker-compose up -d
   ```

3. Access phpLDAPadmin at http://localhost:8080
   - Login DN: `cn=admin,dc=example,dc=com`
   - Password: `admin123`

4. Connect to PostgreSQL using root user:
   ```bash
   PGPASSWORD=ldappass psql -h localhost -U ldapuser -d ldapdb
   ```

5. Connect to PostgreSQL using AD user (john.doe):
   ```bash
   PGPASSWORD=abc psql -h localhost -U john.doe -d ldapdb
   ```

   You should see the following logs in the LDAP server:
   ```bash
    689c4c0c conn=1002 fd=12 ACCEPT from IP=192.168.117.3:42718 (IP=0.0.0.0:389)
    689c4c0c conn=1002 op=0 BIND dn="cn=admin,dc=example,dc=com" method=128
    689c4c0c conn=1002 op=0 BIND dn="cn=admin,dc=example,dc=com" mech=SIMPLE ssf=0
    689c4c0c conn=1002 op=0 RESULT tag=97 err=0 text=
    689c4c0c connection_input: conn=1002 deferring operation: binding
    689c4c0c conn=1002 op=1 SRCH base="ou=people,dc=example,dc=com" scope=2 deref=0 filter="(uid=john.doe)"
    689c4c0c conn=1002 op=1 SRCH attr=1.1
    689c4c0c conn=1002 op=2 UNBIND
    689c4c0c conn=1002 op=1 SEARCH RESULT tag=101 err=0 nentries=1 text=
    689c4c0c conn=1002 fd=12 closed
    689c4c0c conn=1003 op=0 BIND dn="uid=john.doe,ou=people,dc=example,dc=com" method=128
    689c4c0c conn=1003 fd=12 ACCEPT from IP=192.168.117.3:42722 (IP=0.0.0.0:389)
    689c4c0c conn=1003 op=0 BIND dn="uid=john.doe,ou=people,dc=example,dc=com" mech=SIMPLE ssf=0
    689c4c0c conn=1003 op=0 RESULT tag=97 err=0 text=
    689c4c0c conn=1003 op=1 UNBIND
    689c4c0c conn=1003 fd=12 closed
   ```

6. Teardown (including volumes):
    ```bash
    docker-compose down -v
    ```

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