#!/bin/bash

#set this before running
export VAULT_ADDR='http://127.0.0.1:8200'


# Enable postgrSQL secrets engine

vault secrets enable database

# Configure vault with access to postgresql

vault write database/config/my-postgres-db \
	plugin_name=postgresql-database-plugin \
	allowed_roles="readonly-role" \
	connection_url="postgresql://vaultuser:vaultpass@postgres:5432/myapp?sslmode=disable"

# Create a dynamic role

vault write database/roles/readonly-role \
	db_name=my-postgres-db \
	creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
	default_ttl="1h" \
	max_ttl="24h"

# Enable kubernetes auth
vault auth enable kubernetes

#configure kubernetes auth

vault write auth/kubernetes/config \
	token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
	kubernetes_host="https://kubernetes.default.svc" \
	kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

#Create role for app
vault write auth/kubernetes/role/db-app \
	bound_service_account_names="vault-auth" \
	bound_service_account_namespaces="default" \
	audience="vault" \
	policies="db-app-policy" \
	ttl="1h"

# Create a role for service account
vault write auth/kubernetes/roles/postgres-init \
	bound_service_account_names="postgres" \
	bound_service_account_namespace="default" \
	audience="vault" \
	policies="postgres-init-policy" \
	ttl="1h"

# Applying the policy

for file in policy/*.hcl; do
	policy_name=$(basename "$file" .hcl)    #it extracts the file name with out the 
	echo "Uploading policy: $policy_name"
	vault policy write "$policy_name" "$file"
done
