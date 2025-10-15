
# Kubernetes Application with PostgreSQL Database Secured by HashiCorp Vault for Dynamic Secrets Management (open for contribusions)

## Vault integrating in postgresql
- To start the vault in dev mode

       vault status         # to check vault status
       vault server -dev        #to run vault as dev service

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

### HCL(HashiCorp Configuration Language)
We use the policy files with .hcl extention to specify the permissions. There are of two types.
1) **Vault Agent .hcl file (Client-side)** ---> used by agent and Tells the Agent how to authenticate (auto_auth), where to write the token (sink), and optionally how to render secrets (template).

2) **Vault Policy .hcl file (Server-side)** ---> Vault server access policy, we create it using "vault policy write".It defines what a token is allowed to do once it's been issued. it Grants read/write/list/etc. permissions to secrets/data paths.

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

adding the policy for vault

       cat <<EOF > /home/vault/read.policy.hcl
       path "secret/data/my-app/*" {
         capabilities = ["read"]
       }
       EOF

## Prerequirement

1) We need to have a minikube setup locally (this is optimised for minikube, open for contribusions for other clusters).

          minikube start --driver=docker
2) Recomended to use argocd which can reduce the deployment time of the applications

          kubectl create namespace argocd
          kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

          # we can either forward the port or set it to nodeport mode to access the UI

          kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo # to get the admin password
3) Once all the configurations are done, we can configure the vault in the cluster.

          kubectl create namespace vault
   
              # make sure if helm is installed and Add the HashiCorp Helm repo
          helm repo add hashicorp https://helm.releases.hashicorp.com
          helm repo update

              #Create a namespace for Vault
          kubctl create namespace vault

              #installs vault with persistant storage
          helm install vault hashicorp/vault \
                --namespace vault \
                --set "server.dev.enabled=true" \                     #runs Vault in dev mode (for testing)
                --set "server.extraEnvironmentVars.VAULT_DEV_ROOT_TOKEN_ID=root"       #sets root token to root
       kubectl patch svc vault -n vault -p '{"spec": {"type": "NodePort"}}'  # to change the vault pod as nodeport

4) now we can configure the vault 
              
