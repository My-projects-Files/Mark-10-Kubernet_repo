# Spring-boot-webapp Deployment phase

## Argocd for deployinng and monitoring the kubernet cluster

we can use a custom operators to deploy custom Argocd controller so the patching and updates can be taken care.

### Install and deploying the Argocd operator on Kubernetes
Install Operator Lifecycle Manager (OLM), a tool to help manage the Operators running on your cluster.
~~~
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.31.0/install.sh | bash -s v0.31.0
~~~

Install the operator by running the following command:What happens when I execute this command?
~~~
kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
~~~

This Operator will be installed in the "operators" namespace and will be usable from all namespaces in the cluster.

After install, watch your operator come up using next command.
~~~
kubectl get csv -n operators
~~~

Find the details of custom operators at "https://operatorhub.io/operator/argocd-operator"

Now we can deploy the argocd in the cluster with basic configuration and with nodeport mode so we can access it externally

~~~
kubectl apply -f argocd-base.yml
~~~

once deployed we can access the argocd application and access it in web and configure it to get the data from github and deploy it in kubernet cluster and watch the state.

To login to the argocd we need can provide user as admin and the password can be found in secrets file. we can get the password in argocd-cluster secret file.
~~~
echo <password from file> |base64 -d
~~~
