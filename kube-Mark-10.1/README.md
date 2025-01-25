# Deploying a django application using minikube cluster

To apply the file 

kubectl apply -f <file_name> 

## I have used deployments to create pods with auto healing

check deployment.yml

use the ip of pod and 8000 port to curl the app inside the minikube cluster

## I have used services to confige the services

### ip to access the deployed pods using labels and selectors

check network.yml

Labels and selector config needs to be matched with the deployment 

cluser ip

node port

load balancer ( uses CCM and need cloud provider)

with nodeport configured, we can access the app inside the pods using ips of svc outside the minikube since we have access to minikube cluster.

## I have used ingress for the industry level load balancer setup

Check ingress.yml

Name of svc need to be added to the file.

### Note: in case of local setup like minikube, we need to add domain to /etc/hosts entry since we dont have any domains that we can use like amazon.com..etc
