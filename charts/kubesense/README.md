
![Logo](https://kubesense-assets.s3.ap-south-1.amazonaws.com/kubesenselogo.png)


# Kubesense Installation

- [Introduction](#Introduction)
- [Requirements](#Requirements)
- [Installation Using Helm Chart](#Installation-Using-Helm-Chart)

## Introduction
Kubesense has two group of elements one is `server` & another is `sensor`. Each can be deployed in different clusters, If the services needs to be monitored are also present in the same cluster where kubesense servers are running you can use `incluster`  deployment where the server and sensor runs in the same cluster.

## Requirements

### Cluster Requirement
A minimum specification of 
- 2 vCPU(1 Core) + 8 GB memory

### Supported Kubernetes Version
 - GKE
 - EKS 
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
helm repo add kubesense https://tykevision.bitbucket.io
```
(2) Update kubesense Helm repository to fetch latest charts
```
helm repo update kubesense
```
(3) Create custom values to pass for helm deployment
```
cat << EOF > values-custom.yaml
deploymentType: incluster # incluster | server | sensor
cluster_name: k8s-cluster
dashboardHostName: <INGRESS_HOSTNAME_FOR_UI>
aws:
  SENDER_EMAIL: <AWS_SES_EMAIL_CONFIGURED>
  AWS_REGION: <AWS_SES_REGION>
  AWS_ACCESS_KEY: <AWS_ACCESS_KEY>
  AWS_SECRET_KEY: <AWS_SECRET_KEY>
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
deploymentType: server # incluster | server | sensor
cluster_name: k8s-cluster
dashboardHostName: <INGRESS_HOSTNAME_FOR_UI>
aws:
  SENDER_EMAIL: <AWS_SES_EMAIL_CONFIGURED>
  AWS_REGION: <AWS_SES_REGION>
  AWS_ACCESS_KEY: <AWS_ACCESS_KEY>
  AWS_SECRET_KEY: <AWS_SECRET_KEY>
EOF
```

### Deploy Only Sensor
while deploying sensor you need to give the kubeotel_ip, kubeOtelGrpcPort, kubeOtelHttpPort which you would get during server deployment 
```
cat << EOF > values-custom.yaml
deploymentType: sensor # incluster | server | sensor
cluster_name: k8s-cluster
dashboardHostName: <INGRESS_HOSTNAME_FOR_UI>
kubeOtelIp: <KUBEOTEL_IP> # eg. kubesense-kubeotel
kubeOtelGrpcPort: <KUBEOTEL_GRPC_PORT> # eg. 30050
kubeOtelHttpPort: <KUBEOTEL_HTTP_PORT> # eg. 30051
aws:
  SENDER_EMAIL: <AWS_SES_EMAIL_CONFIGURED>
  AWS_REGION: <AWS_SES_REGION>
  AWS_ACCESS_KEY: <AWS_ACCESS_KEY>
  AWS_SECRET_KEY: <AWS_SECRET_KEY>
EOF
```