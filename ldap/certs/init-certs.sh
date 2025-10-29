#!/usr/bin/env bash

set -e

# 1.1 Generate CA private key
openssl genrsa -out ca.key 4096

# 1.2 Create CA self-signed root certificate
openssl req -x509 -new -nodes \
    -key ca.key \
    -sha256 \
    -days 3650 \
    -out ca.crt \
    -subj "/C=US/ST=State/L=City/O=Example Corp/CN=Example Corp Root CA"

echo "✅ Root CA (ca.key, ca.crt) generated."

# 2.1 Generate server private key
openssl genrsa -out server.key 2048

# 2.2 Create SAN configuration file for server (server.cnf)
cat > server.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
C = US
ST = State
L = City
O = Example Corp
CN = localhost

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = ldap.example.com
IP.1  = 127.0.0.1
IP.2  = ::1
EOF

# 2.3 Create server Certificate Signing Request (CSR)
openssl req -new \
    -key server.key \
    -out server.csr \
    -config server.cnf

# 2.4 Sign server certificate with your CA
openssl x509 -req \
    -in server.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out server.crt \
    -days 3650 \
    -sha256 \
    -extfile server.cnf \
    -extensions v3_req

echo "✅ Server certificate (server.key, server.crt, server.cnf) generated."

# 3.1 Generate client private key
openssl genrsa -out client.key 2048

# 3.2 Create configuration file for client (client.cnf)
cat > client.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
prompt = no

[req_distinguished_name]
C = US
ST = State
L = City
O = Example Corp
CN = my-rust-app
emailAddress = rust-app@example.com
EOF

# 3.3 Create client Certificate Signing Request (CSR)
openssl req -new \
    -key client.key \
    -out client.csr \
    -config client.cnf

# 3.4 Sign client certificate with your CA
openssl x509 -req \
    -in client.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -out client.crt \
    -days 3650 \
    -sha256

echo "✅ Client certificate (client.key, client.crt, client.cnf) generated."

# Cleanup
rm server.csr server.cnf client.csr client.cnf
echo "✅ Intermediate files cleaned up."

