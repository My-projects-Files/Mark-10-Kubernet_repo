# Multi-Tenant SaaS Platform on Kubernetes with Dynamic Namespace Provisioning, Ingress Isolation, and GitOps

## deploying this in local minikube

1) staring the minikube

	minikube start --addons=ingress \
  		--cni=calico \
  		--driver=docker
   calico is used to test Network Policies

2) installing the argocd in the cluster

	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

