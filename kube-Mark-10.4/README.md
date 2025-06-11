# Headless service and stateful set 

we need to deploy headless service first before deploying the statefulset as we are working with DNS.

The DNS name of the headless services is defined as
~~~
<statefulset-pod-name>.<headless-svc-name>.<name-space>.svc.cluster.local
~~~

post creation and deploying them. we can check the status if its using the DNS. we can run the below command.
~~~
kubectl run -it --rm --restart=Never --image=busybox dns-test -- nslookup mysql-statefulset-0.my-db-headless-service.default.svc.cluster.local
~~~
