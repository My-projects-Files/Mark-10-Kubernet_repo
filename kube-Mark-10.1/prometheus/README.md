# installing of the prometheus

## first we need to have helm installed in the meachine

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

## we then install prometheus using helm

helm install monitoring prometheus-community/prometheus

## check if it is running 
kubectl get pods

Below Pods should be running

monitoring-alertmanager           ---for alearing purpose

monitoring-alertmanager-headless  ---deployeing aletmanager in headless mode

monitoring-kube-state-metrics     ---it has all the metrics of the k8s like pods,services etc but not the system metrics like cpu,memory etc

monitoring-prometheus-node-exporte ---it exposes system metrics like cpu, memory,disk space etc.

monitoring-prometheus-pushgateway  ---it pushes metrics to Prometheus,which is primarily of pull design.   

monitoring-prometheus-server    --- it is used for launching and running the prometheus application 

## To expose the K8s service in 9090 port as nordport mode, so we can access it in webserver with the cluster ip (minikube ip)

kubectl expose service monitoring-prometheus-server --type=NodePort --target-port=9090 --name=pro-server-ext

## To get the kube state metrix from prometheus server we need to configure it inside prometheus configmap file

kubectl edit cm <promet-server-name> 

To get new data from kube sate metic end point, we can add below enties 
------------------------
- job_name: state_metrics
  static_configs:
  - targets:
     - localhost: <nodeport of kube-state>
------------------------


