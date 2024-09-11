
![Logo](https://kubesense-assets.s3.ap-south-1.amazonaws.com/kubesenselogo.png)

# Kubesense Installation 

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Cluster Requirement](#cluster-requirement)
  - [Supported Kubernetes Version](#supported-kubernetes-version)
  - [Kubernetes RBAC permissions](#kubernetes-rbac-permissions)
- [Installation Using Helm Chart](#installation-using-helm-chart)
  - [Deploy Only Server](#deploy-only-server)
  - [Deploy Only Server](#deploy-only-sensor)
  - [To Add Tolerations and nodeAffinitySelectors](#to-add-tolerations-and-nodeaffinityselectors)
- [External DB setup](#external-db-setup)
  - [External Clickhouse](#external-clickhouse)
  - [External Redis](#external-redis)
- [Ingress](#ingress)

## Introduction
Kubesense has two group of elements one is `server` & another is `sensor`. Each can be deployed in different clusters, If the services needs to be monitored are also present in the same cluster where kubesense servers are running you can use `incluster`  deployment where the server and sensor runs in the same cluster.

## Requirements
[helm](https://helm.sh/docs/intro/install/) & `kubectl`

### Cluster Requirement
A minimum specification of 
- 4 vCPU(1 Core) + 16 GB memory

### Supported Kubernetes Version
 - GKE
 - EKS 
 - AKS
 - Self Managed
 - Minikube

### Kubernetes RBAC permissions
Resources: nodes, pods, deployments, statefulsets
Access: get, list, watch

KubeSensor (Kind: `Daemonsets`)

Requires `Privileged` Container Access for kubesensor(EBPF)

    APIGroup: ""
    Access: get, list, watch
    Resources:   
    - nodes
    - namespaces
    - configmaps
    - services
    - pods
    - replicationcontrollers

    APIGroup: apps
    Access: get, list, watch
    Resources:
    - daemonsets
    - deployments
    - replicasets
    - statefulsets

    APIGroup: extensions, networking.k8s.io
    Access: get, list, watch
    Resources:
    - ingresses

    APIGroup: route.openshift.io
    Access: get, list, watch
    Resources:
    - routes

Kubecol (Kind: `Deployement`)

    APIGroup: ""
    Access: get, list, watch, create, update
    Resources: 
    - endpoints
    - services
    
## Installation Using Helm Chart

(1) Add Helm repo
```
helm repo add kubesense https://helm.kubesense.ai
```
(2) Update kubesense Helm repository to fetch latest charts
```
helm repo update kubesense
```
(3) Create custom values to pass for helm deployment
```
cat << EOF > values-custom.yaml
global:
  deploymentType: server | sensor
  cluster_name: k8s-cluster
  dashboardHostName: <INGRESS_HOSTNAME_FOR_UI>
  redis:
    password: <REDIS_PASSWORD> # {optional} if not specified will autogenerate
  clickhouse:
    password: <CLICKHOUSE_PASSWORD> # {optional} if not specified will autogenerate
  mysql:
    password: <MYSQL_PASSWORD> # {optional} if not specified will autogenerate
EOF
```
(4) Deploy kubesense release
```
helm upgrade -i kubesense kubesense/kubesense --create-namespace -n kubesense -f values-custom.yaml
```

the above example is for deploying incluster deployment check below examples for server and sensor only deployments

### Deploy Only Server
```
cat << EOF > values-custom.yaml
global:
  deploymentType: server # incluster | server | sensor
  cluster_name: k8s-cluster
  ingress:
    enabled: false
    className: nginx
  dashboardHostName: <INGRESS_HOSTNAME_FOR_UI>
  redis:
    password: <REDIS_PASSWORD> # {optional} if not specified will autogenerate
  clickhouse:
    password: <CLICKHOUSE_PASSWORD> # {optional} if not specified will autogenerate
  mysql:
    password: <MYSQL_PASSWORD> # {optional} if not specified will autogenerate
EOF
```

### Deploy Sensor
while deploying sensor you need to give the kubeAggregator_ip, kubeAggregatorGrpcPort, kubeAggregatorHttpPort which you would get during server deployment 
```
cat << EOF > values-custom.yaml
global:
  deploymentType: sensor # incluster | server | sensor
  cluster_name: k8s-cluster
  dashboardHostName: <INGRESS_HOSTNAME_FOR_UI>
  kubeAggregatorIp: <KUBEAGGREGATOR_IP> # eg. kubesense-kubeAggregator
  kubeAggregatorGrpcPort: <KUBEAGGREGATO_GRPC_PORT> # eg. 30050
  kubeAggregatorHttpPort: <KUBEAGGREGATO_HTTP_PORT> # eg. 30051
EOF
```

### To Add Tolerations and nodeAffinitySelectors
```
global:
  ...
  nodeAffinityLabelSelector:
    - matchExpressions:
        - key: app
          operator: In
          values: kubesense
  tolerations:
    - key: "app"
      operator: "Equal"
      value: "kubesense"
      effect: "NoSchedule"
```

### External DB setup
## External Clickhouse
```
...
externalClickHouse:
  enabled: true  ## Enable external ClickHouse
  type: ep
  clusterName: default 
  storagePolicy: default 
  username: default ## External ClickHouse username
  password: password ## External ClickHouse Password
  host:
  - ip: 10.1.2.3
    port: 9000
clickhouse:
  enabled: false    
```

## External Redis
```
...
externalRedis:
  enabled: true
  host: 10.1.2.3
  port: 6379
  password: defaultPass
redis:
  enabled: false
```

### Ingress
In order to access kubesense application we want to enable ingress for `kubesense-webapp` 
```
service:
  name: kubesense-webapp
port: 80
```
example configuration of ingress using nginx-ingress
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubesense-webapp
  namespace: kubesense
spec:
  ingressClassName: nginx
  tls:
  - hosts:
      - "app.kubesense.ai"
    secretName: kubesense.ai-certs
  rules:
    - host: "kubesense.tyke.ai"
      http:
        paths:
          - path: /
            pathType: ImplementationSpecific
            backend:
              service:
                name: kubesense-webapp
                port:
                  number: 80
```
`note: The example above works with nginx-ingress controller and expects to have a secret containing tls certificates in the name of kubesense.ai-certs`
