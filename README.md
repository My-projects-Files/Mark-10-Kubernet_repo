# Mark-10
This is for the Kubernet practice

# Architecture
inside a minikube cluster we can find the kubernets architectual config file in the below path.
~~~
minikube ssh
sudo ls -l /etc/kubernetes/manifests
~~~
This path include config files like etcd, kube-apiserver, kube-controller-manager, kube-scheduler.

## Controllers

In Kubernetes, controllers are core components that watch the cluster state and automatically make changes to move the actual state toward the desired state defined in your YAML configurations.

So in short it matched the actual state with the desired state.

## Kustomize

Kustomize is a tool built into kubectl (and used by ArgoCD) that helps you manage Kubernetes YAML files without modifying the original files.

we can Think of it like a way to customize our Kubernetes manifests by layering or combining them.

### Use case for Kustomize

we compose multiple YAML files together. we can patch or override some values without changing original files. It helps manage different environments (dev, staging, prod) by applying different configs. It also avoids duplicating YAML files.

we create a file called kustomization.yaml in a folder. Inside, our list the resources (YAML files or other folders) you want to deploy.

            resources:
              - deployment.yaml
              - service.yaml

## Pod Disruption Budget (PDB)

Pod disruption is the process, when pod got stopped or evicted. Types of disruptions are 

- **Voluntary** : These are intentional and usually planned by humans or controllers. something like "kubectl delete pod"
- **Involuntary** : These are unplanned and caused by failures or system-level issues. something like "Node crash" (or) "OOM" (or) "Disk failure" etc.

Pod Disruption Budget is a policy that limits, how many pods that can be voluntarily disrupted at a time. it help maintain high availability during planned operations like "Rolling updates" (or) "kubectl drain" etc. 

- **Note**: PDB only applies to Voluntary disruption only and cant be applied for causes like pod crashes or anything


## Pause Container in a Pod

The pause container is a minimal container that serves as the “infrastructure anchor” for a Pod. it's the first container started when Kubernetes creates a Pod, and all the other containers in the Pod share its Linux namespaces — especially the network namespace.

When a Pod is started, it will be given an namespace(network, IPC, PID, etc.), But they need a running process to keep them alive. if not then the namespace will be exited. 

So the Pod lauched a Pause container which just sits there and does nothing except keep the network and namespace alive. It uses very little CPU or memory. so multiple container can be deployed in the pod who can communicate throuch same ip address. They can connect each other VIA localhost. if an application container restarts the pause container will hold the namespace so the pod ip remains same.

**NOTE**: Pause container lanches before the init container. below is the flow.

      Pause Container --> creates a namespace
          |
          V      
      init Container  --> Run before app and should be successful
          |
          V
      App Container --> application is launched here
      


## Headless and statefulset
- **Headless** : A Headless Service is a special kind of Kubernetes Service that does not have a Cluster IP assigned. Instead of load-balancing traffic through a single virtual IP, it lets you directly reach the individual pods.
- **Statefulset** : it manages deployments and scaling of stateful applications, ensuring each pod maintains a unique and persistent identity, stable networking, and ordered deployment and scaling



## Simple way to generate a deployment file in k8s.
For generating a nginx deployment file
~~~
kubctl create deployment my-nginx --image=nginx:latest --port=80 --dry-run=client -o yaml > deployment.yml
~~~

To generate a service for the above deployment 
~~~
kubectl expose deployment my-nginx --port=80 --target-port=8080 --type=ClusterIP --dry-run=client -o yaml > service.yml
~~~

- **dry-run=client** : it validates and prints the output locally without contacting the API server.
- **dry-run=server** : it will send request to the Kubernetes API server, run full validation, run admission webhooks, but don’t save or implement themanything.



# Project-1

### Kubernetes Installation Using KOPS on EC2

Create an EC2 instance or use your personal laptop.
Dependencies required

Python3
AWS CLI
kubectl
### Install dependencies
~~~
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y python3-pip apt-transport-https kubectl
pip3 install awscli --upgrade
export PATH="$PATH:/home/ubuntu/.local/bin/"
~~~
### Install KOPS (our hero for today)
~~~
curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64

chmod +x kops-linux-amd64

sudo mv kops-linux-amd64 /usr/local/bin/kops
~~~
### Provide the below permissions to your IAM user. If you are using the admin user, the below permissions are available by default
AmazonEC2FullAccess
AmazonS3FullAccess
IAMFullAccess
AmazonVPCFullAccess
### Set up AWS CLI configuration on your EC2 Instance or Laptop.
~~~
Run aws configure
~~~
## Kubernetes Cluster Installation
Please follow the steps carefully and read each command before executing.

Create S3 bucket for storing the KOPS objects.
aws s3api create-bucket --bucket kops-abhi-storage --region us-east-1
Create the cluster
~~~
kops create cluster --name=demok8scluster.k8s.local --state=s3://kops-abhi-storage --zones=us-east-1a --node-count=1 --node-size=t2.micro --master-size=t2.micro  --master-volume-size=8 --node-volume-size=8
~~~
### Important: Edit the configuration as there are multiple resources created which won't fall into the free tier.
~~~
kops edit cluster myfirstcluster.k8s.local
~~~
## Step 12: Build the cluster
~~~
kops update cluster demok8scluster.k8s.local --yes --state=s3://kops-abhi-storage
~~~
This will take a few minutes to create............

After a few mins, run the below command to verify the cluster installation.

kops validate cluster demok8scluster.k8s.local


## kubectl cheat sheet 
~~~
https://kubernetes.io/docs/reference/kubectl/quick-reference/
~~~

# Project-2
## Automated CI/CD Pipeline for Kubernetes with jenkins
To manually deploy this app
we have a notejs webapp and the dependencised of it inside the package.json file. we can to run the docker file to create an image
~~~
docker build -t puyt:latest .
~~~
then
we can deploy the image in the kubernet using the deployments.
~~~
kubectl run -d --name=python_app -p 3000:3000 deployment.yml
~~~

we can also automate the process using the jenkins CI/CD Pipelines
Run the jenkins pipeline from git repo 


## Lauch an ArgoCD inside the minikube cluster
I have deployed the argocd namespace inside the running minikube cluster and opened the 8080 port for access it through the web UI
### Install ArgoCD in the Kubernetes Cluster
You can install ArgoCD in your Kubernetes cluster using kubectl.

Install ArgoCD: First, apply the ArgoCD installation manifests:
~~~
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
~~~
Expose ArgoCD API Server: You need to expose the ArgoCD API server so you can access it in your browser:
~~~
kubectl port-forward svc/argocd-server -n argocd 8080:443
~~~
Now, you can access the ArgoCD UI at https://localhost:8080.

### Login to ArgoCD
The default username is admin. You can find the password using the following command:
~~~
kubectl get pods -n argocd
kubectl describe secret argocd-initial-admin-secret -n argocd #if its not encripted
(or)
kubectl get secret argocd-initial-admin-secret -n argocd -o=jsonpath='{.data.password}' | base64 --decode #if its encripted
~~~
Look for the password field and copy it. Then login to the ArgoCD UI at https://localhost:8080 using admin as the username and the copied password.

Create a GitHub Repository for Your Application, Kubernetes manifests for your application.So ArgoCD can track it


### Create a new Application in ArgoCD: You can create an application manually through the ArgoCD UI, or use the CLI.

To create it via CLI:
~~~
argocd app create my-app \
  --repo https://github.com/your-username/my-app-repo.git \
  --path k8s \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
~~~
Replace your-username and my-app-repo with actual repository details.

Sync the application: Once the application is created, you can sync it to apply the configuration:
~~~
argocd app sync my-app
~~~
Alternatively, from the ArgoCD UI, you can click on your app and press "Sync" to deploy the changes to your Kubernetes cluster.

We can check the app inside the cluster 
~~~
kubectl get deployments
kubectl get svc
~~~

### Clean Up Resources
Once you're done testing, you can delete the resources created by ArgoCD to avoid leaving unnecessary resources running:
~~~
argocd app delete my-app
~~~
You can also uninstall ArgoCD from your Kubernetes cluster:
~~~
kubectl delete namespace argocd
~~~



# Operators for kubernet controller tools (ArgoCD)

we can use operators to install and manage controller for k8s tools like argocd.

Check the webside for operator supported contollers
~~~
https://operatorhub.io/
~~~


# Ingress in kubernet
we can assign multiple services and access them using host base or path based access.
ingress needs ingress controller along with ingress.yml to work properly.
The most common Ingress controller is the NGINX Ingress Controller. You can install it with the following command:

Install NGINX Ingress Controller via Helm (if using Helm):
~~~
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace
~~~

Install NGINX Ingress Controller via kubectl (without Helm):
~~~
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/stat
~~~
You can find the Ingress Controller deployment by checking for deployments in the namespace where it's typically installed. For example, to find the Ingress controller in the ingress-nginx namespace:
~~~
kubectl get deployments -n ingress-nginx
~~~
This will show you if there’s an Ingress controller deployment, and you should see a deployment like nginx-ingress-controller or something similar.
## ingress controller for minikube
we can install ingress in minikube with pre-existing configurations.
~~~
minikube addons enable ingress
~~~
# Kubernetes questions and Scenarios
- **Scenarios-1**:Pod CrashLoopBackOff(A pod keeps restarting with CrashLoopBackOff)
Debug steps
~~~
#get the pod details
kubectl get pods -n <namespace>

#To get the logs of the crashed pods
kubectl logs <pod-name> -n <namespace> --previous

#describe the pods
kubectl describe pod <pod-name> -n <namespace>
~~~
Resolution
~~~
#To open it interactively
kubectl run debug-pod --rm -it --image=<your-image> -- bash

#To check out rollout history and to rollback
kubectl rollout history deployment/<deployment-name> -n <namespace>
kubectl rollout undo deployment/<deployment-name> -n <namespace>
~~~

- 
