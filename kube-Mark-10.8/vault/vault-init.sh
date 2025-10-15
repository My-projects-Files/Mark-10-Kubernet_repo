#!/bin/bash

#set this before running
export VAULT_ADDR='http://vault.vault.svc.cluster.local:8200'


# Enable postgrSQL secrets engine
vault secrets enable database
# Enable kubernetes auth
vault auth enable kubernetes

# Applying the policy
for file in policy/*.hcl; do
	policy_name=$(basename "$file" .hcl)    #it extracts the file name with out .hcl
	echo "Uploading policy: $policy_name"
	vault policy write "$policy_name" "$file"
done
# Configure vault with access to postgresql

vault write database/config/my-postgres-db \
	plugin_name=postgresql-database-plugin \
	allowed_roles="readonly-role,db-init-role" \
	connection_url="postgresql://vaultadmin:vaultpass@postgres-0.postgres.default.svc.cluster.local:5432/myapp?sslmode=disable"    			#get the vault password from secrets with base64 encryption

# Create a dynamic role for the application

vault write database/roles/readonly-role \
	db_name=my-postgres-db \
	creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
	default_ttl="1h" \
	max_ttl="24h"

# Creat a dynamic role for db

vault write database/roles/db-init-role \
    db_name=my-postgres-db \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}'; GRANT ALL PRIVILEGES ON DATABASE myapp TO \"{{name}}\";" \
    default_ttl="10m" \
    max_ttl="1h"

#configure kubernetes auth

vault write auth/kubernetes/config \
	token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
	kubernetes_host="https://kubernetes.default.svc" \
	kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

#Create role for app
vault write auth/kubernetes/role/db-app \
	bound_service_account_names="vault-auth" \
	bound_service_account_namespaces="default" \
	audience="https://kubernetes.default.svc.cluster.local" \			#since we are using the local setup, we need to match the aud for pod agent and side car
	policies="db-app-policy" \
	ttl="1h"

# Create a role for service account
vault write auth/kubernetes/role/postgres-init \
  bound_service_account_names="postgres" \
  bound_service_account_namespaces="default" \
  audience="https://kubernetes.default.svc.cluster.local" \				#since we are using the local setup, we need to match the aud for pod agent and side car
  policies="postgres-init-policy" \
  ttl="1h"




