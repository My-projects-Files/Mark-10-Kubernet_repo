# Enable postgrSQL secrets engine

vault secrets enable database

# Configure vault with access to postgresql

vault write database/config/my-postgres-db \
	plugin_name=postgresql-databasse-plugin \
	allowed_roles="readonly-role" \
	connection_url="postgresql://vaultuser:vaultpass@postgres:5432/myapp?sslmode=disable"

# Create a dynamic role

value write database/roles/readonly-role \
	db_name=my-postgres-db
		
