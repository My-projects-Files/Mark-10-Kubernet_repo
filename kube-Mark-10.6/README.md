# Microservices App with API Gateway

This is a kubernets adoptation of the Dock-proj9, we will deploy a user and order and there services and join them with ingress config.

If you're using Minikube, enable NGINX ingress:

		minikube addons enable ingress

To generate a ingress file for those two servers 

		kubectl create ingress my-ingress --rule="myapp.local/users*=my-user:80" --rule="myapp.local/orders*=my-order:80" --dry-run=client -o yaml > ingress.yml
  
