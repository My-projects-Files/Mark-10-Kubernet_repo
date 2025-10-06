


## vault the postgresql

we can use the below command to vault the postgresql.

    vault write database/config/my-postgres-db \             #creates a named database configuration
      plugin_name=postgresql-database-plugin \               #Plugins
      allowed_roles="readonly-role" \                        #only this role can be able to dynamically generate credentials for this DB.
      connection_url="postgresql://vaultuser:vaultpass@postgres:5432/myapp?sslmode=disable"

This is the actual PostgreSQL connection string Vault will use to log in to the DB.

    connection_url="postgresql://vaultuser:vaultpass@postgres:5432/myapp?sslmode=disable"

    postgresql://<user>:<password>@<host>:<port>/<database>?<options>

**vaultuser**: PostgreSQL user that Vault uses to connect. they need to have previolages to create user, grant role/Permission, and password rotation.
**vaultpass**: Password for that user
**postgres**: Hostname of your Postgres server (maybe Docker container name)
**5432**: Default Postgres port
**myapp**: Database name
**sslmode=disable**: Disables SSL (for local/dev use)

