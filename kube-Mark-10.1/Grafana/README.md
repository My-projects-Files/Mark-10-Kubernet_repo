# To install grafana post installing the prometheus in the cluster

## To download grafana using helm
helm repo add grafana https://grafana.github.io/helm-charts

helm repo update

## To install grafana in cluster

helm install grafana grafana/grafana

## To get the admin users password details, we can use below command

1. Get your 'admin' user password by running:

   kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo


2. The Grafana server can be accessed via port 80 on the following DNS name from within your cluster:

   grafana.default.svc.cluster.local

   Get the Grafana URL to visit by running these commands in the same shell:
     export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
     kubectl --namespace default port-forward $POD_NAME 3000

3. Login with the password from step 1 and the username: admin

## To expose the Grafana service

kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-ext

## Post login to Grafana we need to add the predefined prometheus as data source

data source ---> prometheus ---> ipaddress and nodeport details

## we can set custome dash board or use the default dashboard "3662"
