#!/bin/bash

# Redis Leader 
kubectl apply -f https://raw.githubusercontent.com/tkeijock/k8s-eks-showcase/refs/heads/main/k8s/deployment-redis-leader.yaml

# Deploy Redis Follower
kubectl apply -f https://raw.githubusercontent.com/tkeijock/k8s-eks-showcase/refs/heads/main/k8s/deployment-redis-follower.yaml

# Deploy Frontend 
kubectl apply -f https://raw.githubusercontent.com/tkeijock/k8s-eks-showcase/refs/heads/main/k8s/deployment-frontend.yaml

# Service for Redis Leader (APP for Write data) 
kubectl apply -f https://raw.githubusercontent.com/tkeijock/k8s-eks-showcase/refs/heads/main/k8s/service-redis-leader.yaml

# Service for Redis Follower ( APP comunication to Read data)
kubectl apply -f https://raw.githubusercontent.com/tkeijock/k8s-eks-showcase/refs/heads/main/k8s/sevice-redis-follower

# Service for frontend (type Loadbalancer)
kubectl apply -f https://raw.githubusercontent.com/tkeijock/k8s-eks-showcase/refs/heads/main/k8s/service-fronted-eks.yaml

# Check all 
kubectl get all
