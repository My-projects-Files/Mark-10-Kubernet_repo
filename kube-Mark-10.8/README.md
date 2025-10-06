


### vault the postgresql

we can use the below command to vault the postgresql.

vault write database/config/my-postgres-db \
  plugin_name=postgresql-database-plugin \
  allowed_roles="readonly-role" \
  connection_url="postgresql://vaultuser:vaultpass@postgres:5432/myapp?sslmode=disable"


