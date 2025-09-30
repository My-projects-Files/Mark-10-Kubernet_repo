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
	
	you can set the service as nodeport or you can run port-forward

		kubectl port-forward svc/argocd-server -n argocd 8080:443
	we can access this using https://localhost:8080

3) Install cert-manager with Self-Signed Issuer

 			kubectl create namespace cert-manager
			helm repo add jetstack https://charts.jetstack.io
			helm install cert-manager jetstack/cert-manager \
			  --namespace cert-manager --set installCRDs=true
   **Self-signed ClusterIssuer**:
   
		   			apiVersion: cert-manager.io/v1
					kind: ClusterIssuer
					metadata:
					  name: self-signed
					spec:
					  selfSigned: {}
4) now we can deploy the demo app with the help of helm chart.

		helm install tenant-a ./tenant-app -n tenant-a --create-namespace

	if NetworkPolicy needs to be disabled then we can use 

		helm install tenant-a ./tenant-app -n tenant-a --create-namespace \
  		--set networkPolicy.enabled=false
5) need to integrate argocd along with helm for quick deployment 
