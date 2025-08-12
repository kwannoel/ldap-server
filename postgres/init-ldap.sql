-- Create LDAP users in PostgreSQL
-- These users will authenticate via LDAP but need to exist in PostgreSQL

-- Create user john.doe if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'john.doe') THEN
        CREATE USER "john.doe";
        GRANT CONNECT ON DATABASE ldapdb TO "john.doe";
        GRANT USAGE ON SCHEMA public TO "john.doe";
    END IF;
END
$$;