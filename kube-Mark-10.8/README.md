


## Vault the postgresql

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

- To store the vaule inside the vault we can use this 

        vault kv put secret/postgres/init \
          POSTGRES_USER=<vaultuser> \
          POSTGRES_PASSWORD=<vaultpass>
## Setup

As the app should not directly connect to the vault so we have setup a sidecar container in the deployment and mounted a voulume where the credentials will be stored by vault and retrived by application.

### vault-agent-config.hcl
It’s a required configuration file for the Vault Agent inside the pod, we will define this in configmap so it can be injected into the vault agent(sidecar) inside the pod.

            exit_after_auth = false
            pid_file = "/home/vault/pidfile"
            
            auto_auth {
              method "kubernetes" {
                mount_path = "auth/kubernetes"
                config = {
                  role = "db-app"
                }
              }
            
              sink "file" {
                config = {
                  path = "/home/vault/.vault-token"
                }
              }
            }
            
            template {
              destination = "/vault/secrets/db-creds.txt"
              contents = <<EOT
              {{ with secret "database/creds/readonly-role" }}
              username={{ .Data.username }}
              password={{ .Data.password }}
              {{ end }}
              EOT
            }

- This explains the agent how to authenticate (e.g. using Kubernetes, AWS, etc.).
- Where to write the vault token (sink)
- Whether to render secrets into files (template blocks)
