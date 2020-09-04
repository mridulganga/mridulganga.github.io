---
title: "Kubernetes what and how"
date: 2020-08-31T20:14:45+05:30
slug: "basics-k8s"
description: "kubernetes quickstart guide"
keywords: []
draft: false
tags: ["kubernetes","devops","tech"]
math: false
toc: true
---

Kubernetes is a relatively new term which is in talks a lot. In this article I will try to explain what
kubernetes is and how we can quickly get started with it.

### Before you start
- you should have some basic understanding of linux
- you should know what are containers
- some docker knowledge would be useful

## What are containers?
Containers can be seen as lightweight VMs. Though they are much different. 
When we want to run our application in a VM - we need to install an OS and application requirements,
following which we can run our application. Doing this takes a lot of time, space and a lot of processing
power and memory goes to waste in maintaining the OS.

What if we could only package our application with the requirments and run them anywhere? thats what containers
are for. Containers generally use a base image (ubuntu, python, golang etc) and you can install your
application requirements over it. For doing this we make use of a `Dockerfile`. This is where we specify
the base image, the ports, the requirements and application files etc. So, after writing the Dockerfile - 
we build the docker image, to manage the docker images we make use of docker registries (can be local
or somewhere in cloud). Later we can spawn as many containers from the registry images.

Explaining more about docker is not in scope of this article but check [this cheatsheet](https://www.docker.com/sites/default/files/d8/2019-09/docker-cheat-sheet.pdf) for most commonly used docker commands.

Sample Dockerfile for a simple flask application
```dockerfile
# Dockefile
FROM python:3

WORKDIR /usr/src/app

COPY . .
RUN pip install -r requirements.txt

EXPOSE 5000
CMD [ "python", "./main.py" ]
```

So, now we know that docker provides an easy and faster way to package and run applications.
But, we can only run docker on one machine at a time. That's where kubernetes comes in.

## what is kubernetes?
Kubernetes is a portable, extensible, open-source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation. Thats the technical definition. 
In more easy terms - we manage the lifecycle of containers accross multiple machines using kubernetes (orchestration).

To know more about kubernetes [check this very nice documentation](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)

Kubernetes manages all of its resources using yaml files. There are many resources in kubernetes which help
making and running an application, scaling, managing access, routes etc.

### Basic Resource Types
- pods  (synonymous to containers)
- deployments   (everything needed to run the application)
- services  (defines ports and load balancers for application)

The above resouce types are the most basic ones we need to run and access our application.
We also make use of other resources like - nodes, daemon set, secrets, config maps, ingress, volume resources etc.

We can spend a week to discuss and know what and how to use all the resource types, but lets jump in and see
how to deploy a simple application.

## Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-deployment
  labels:
    app: appname
# below starts the deployment spec
spec:
  replicas: 3
  selector:
    matchLabels:
      app: appname
  template:
    metadata:
      labels:
        app: appname
    # below starts the pod spec
    spec:
      containers:
        - name: appname
          image: "nginx"
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

To explain the above fields - 

apiVersion - version of kubernetes resource in use, depending on the version, the yaml format may change

kind - the type of kubernetes resource (deployment, service etc)

metadata
    name - name of the deployment
    labels - labels of the deployment. this is used to map this deployment with other resources like a service. 

spec - configuration of the deployment/ pod/ service the format depends on the kind

replicas - number of pods to create (horizontal scaling)

selector - used to map resources together (using the labels), if deployment has a label `app: app1`
we can then use the following in a service to map the service to the deployment. We can use multiple labels.
```yaml
selector:
    macthLabels:
        app: app1
```

template - this is present in a deployment and this is where we define our pod config
we tell the metadata and labels like we did for deployment along with the spec (for the pod)

Inside the pod spec we have list of containers with relevant info(name, image, env, ports, volumes etc)

## Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-service
  labels:
    app: appname
spec:
  type: NodePort   # ClusterIP/ LoadBalancer
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app: appname

```

In the above example the spec is different, Service only takes care of the port mappings.
The other thing we see is the selector - this is used to map the service to the deployment.
So if the deployment created 3 pods (replicas), our service will automatically create a load balancer,
and you will be able to access the application on `app-service:80`.

### Service Types
- ClusterIP - this creates a internal loadBalancer for the pods, this is not accessable from outside our kubernetes environment.
- NodePort - kubernetes can run on multiple machines(nodes) NodePort exposes our service to a port on the Node(single or multiple)
- LoadBalancer - create an external service load balancer (this is not used as much, we rather use ingress)


## Running kubernetes on linux machine
Now that we have yaml files ready to be deployed to a kubernetes cluster, lets install kubernetes on local linux machine.

### Options (Flavours)
- minikibe
- microk8s
- using kubeadm cli tool
- k3s (smallest and easiest)

We will use k3s for our usecase. It's lightweight and easiest to setup.

### Install k3s -
```bash
curl -sfL https://get.k3s.io | sh -
# installation done, check if it works
k3s kubectl get node
# more info at https://k3s.io/
```

### Deploy deployment and service
Now we have a kubernetes cluster running locally. Save the above deployment yaml and service yaml to files `deployment.yaml` and `service.yaml`. Then run the following command to apply the changes in the cluster - 
```bash
# apply
k3s kubectl apply -f deployment.yaml
k3s kubectl apply -f service.yaml
# check if resources were created
k3s kubectl get deploy
k3s kubectl get pod
k3s kubectl get svc
```
#### kubectl
kubectl can also be installed as a standalone tool from [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/).
to know about more kubectl commands try - 
```bash
k3s kubectl help
```

### Verify application is running
If the deployment and service got created without errors, we should now be able to access it on 
[http://localhost](http://localhost)


## Other useful resources - 
- [ingress example](https://github.com/nginxinc/kubernetes-ingress/blob/master/examples/complete-example/cafe-ingress.yaml)
- [helm](https://helm.sh/)
- [prometheus](https://prometheus.io/)
- [grafana](https://grafana.com/)
- [rancher](https://rancher.com/)