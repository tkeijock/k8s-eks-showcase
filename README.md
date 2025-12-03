# k8s-test : Overview 

This repository exists to document my learning journey while exploring Kubernetes , specifically using AWS EKS (Elastic Kubernetes Service). This repository serves as a permanent reference for the essential steps, concepts, and commands required to reproduce the entire setup whenever needed.

The idea is not just to store notes, but to provide a structured guide that enables me to:

- Have a central place to revisit configuration and deployment steps without repeatedly searching for scattered information

- Experiment locally—using a controlled test environment—before applying the same concepts to production workloads on EKS

- Understand how Kubernetes behaves when running inside AWS, especially in terms of scalability, availability, and infrastructure integration


# 🏗️ Architecture Overview

## EKS overview
When working with Kubernetes, we rely on a cluster to provide the underlying infrastructure required to run and manage containerized applications.
In a traditional on-premises setup, I would be responsible for provisioning and maintaining these elements manually. 

AWS removes that operational burden through EKS by provisioning a fully managed Kubernetes control plane and uses EC2 instances as worker nodes to run workloads. By leveraging EC2, these nodes inherit the capabilities of the AWS cloud, including:
- High availability
- Automatic scalability 
- Multi-AZ redundancy 
- Native AWS integrations 

In essence, EKS provides Kubernetes with cloud-grade reliability, where EC2 instances act as worker nodes that I can manage directly through kubectl.

## EKS vs Minikube 
Minikube provides a lightweight, local Kubernetes cluster that runs inside a single virtual machine. It does not create multiple virtual machines, nor multiple physical nodes . Instead, it simulates a Kubernetes cluster by running all core components (control plane + worker node) on the same machine (the nodes are logical, not separate machines).

In this test environment, I will use Minikube to simulate a Kubernetes cluster inside a single EC2 instance. Minikube provides a lightweight, local cluster that is perfect for learning and experimentation.

Without Minikube, I would need to provision multiple EC2 instances, configure them as Kubernetes nodes, and manage all the required infrastructure myself — something that only makes sense later, when moving to a real EKS production environment.

### Minikube: Local vs Virtual
When running Minikube on a local machine, a virtualization layer is required—typically something like VirtualBox. However, when using a virtualized environment such as an EC2 instance, an additional hypervisor is not needed, because the instance already provides the underlying virtualization required for Minikube's nodes.


---
# Testing :

## testing enviroment overview : 
- Create a EC2 instance
- Kubectl  
- Install Docker
- Install Minikube

## 🖥️ Create a EC2 Instance
1️⃣ Access the AWS Console:

Log into your AWS account , Navigate to EC2,  Click Launch instance:

2️⃣ Instance Configuration

AMI= Ubuntu Server 18.04 LTS (HVM), SSD Volume Type

Instance Type= t3.small  with  2 vCPU / 2 GB

SSH Key Pair=	Use an existing key or create a new one

 Why t3.small instead of t2.micro?
 
Minikube requires more memory. The free-tier t2.micro (1 vCPU, 1 GB RAM) is insufficient and Minikube will fail to run properly.
The t3.small offers 2 GB RAM, which is enough for this setup.

Note: The t3.small costs roughly twice as much as a t2.micro, but since this instance is for development and not running 24/7, the monthly cost remains low.

3️⃣ Connect to the instance:

Open an SSH client. (If using Windows, you may use PuTTY or another SSH tool.)
Locate your private key file (.pem) used when launching the instance.
Ensure the key has the correct permissions (it must not be publicly viewable). change permision to file:

```chmod 400 <your-key-file>.pem``` 

Connect to your instance using its Public DNS or Public IP. Use the appropriate username for your AMI (e.g., ec2-user, ubuntu, admin, centos):

``` ssh -i "<your-key-file>.pem" <username>@<public-dns-or-ip>``` 

## 🖥️ Install Kubectl
Must be inside the instance:

Linux: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

Windows: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

```bash

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/

kubectl help  
```

## 🖥️ Install Docker

apt-get : Usually the most convenient option because it resolves dependencies automatically and integrates with the OS package manager.

```bash
sudo apt-get update
sudo apt-get install docker.io -y
```
OR 

 Curl : Works on almost any Linux distribution, but does not manage dependencies by itself.

```bash
curl -fsSL https://get.docker.com | sudo sh
```

## 🖥️ Install Minikube

https://minikube.sigs.k8s.io/docs/start/

1️⃣ Install

```bash
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
```


2️⃣ Start

```bash
minikube start --driver=docker
```

> --driver= None  must NOT be used in production !!! 
This mode is intended exclusively for testing, development, or learning environments. In this configuration, Kubernetes components run directly on the host with elevated privileges, which can introduce security and stability risks.

