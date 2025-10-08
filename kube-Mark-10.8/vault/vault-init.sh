#!/bin/bash

#set this before running
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'


# Enable postgrSQL secrets engine

vault secrets enable database

# Configure vault with access to postgresql

vault write database/config/my-postgres-db \
	plugin_name=postgresql-databasse-plugin \
	allowed_roles="readonly-role" \
	connection_url="postgresql://vaultuser:vaultpass@postgres:5432/myapp?sslmode=disable"

# Create a dynamic role

value write database/roles/readonly-role \
	db_name=my-postgres-db \
	creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNIT '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
	default_ttl="1h"\
	max_ttl="24h"

# Enable kubernetes auth
vault auth enable kubernetes

#configure kubernetes auth

vault write auth/kubernetes/config \
	token_reviewer_jwt="<service_account_token>" \
	kubernetes_host="https://kubernetes.default.svc" \
	kubernetes_ca_cert=@/path/to/ca.crt

#Create role for app
vault write auth/kubernetes/role/db-app \
	bound_service_account_names="vault-auth" \
	bound_service_access_namespaces="default" \
	policies="db-app" \
	ttl="1h"

