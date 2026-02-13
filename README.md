# k8s-eks-showcase : Overview 

This repository documents my learning journey exploring Kubernetes, specifically on AWS EKS (Elastic Kubernetes Service). It serves as a permanent reference for the steps, concepts, and commands needed to reproduce the setup.

The goal is not just to store notes, but to provide a structured guide that allows me to revisit configurations easily, experiment locally in a test environment, and understand how Kubernetes behaves in AWS in terms of scalability, availability, and integration with cloud services.

All configurations are first validated in a lightweight local cluster using Minikube before being deployed to EKS, ensuring a smooth development-to-production workflow.

This repository builds upon the Alura course on Kubernetes and AWS EKS, where I learned the foundational concepts and best practices. I have complemented the course material with my own analyses, insights, and experiments, turning this repository into a personal reference that reflects both the official guidance and my practical learning journey.

# 🏗️ Architecture Overview

## EKS overview

When working with Kubernetes, we rely on a cluster to provide the underlying infrastructure required to run and manage containerized applications. In a traditional on-premises setup, provisioning and maintaining this infrastructure manually is time-consuming and operationally heavy.

AWS EKS removes that burden by providing a fully managed Kubernetes control plane, while EC2 instances serve as scalable and highly available worker nodes that I manage directly through kubectl.

Although the goal of this repository is to deploy a real application to EKS, all manifests are validated in a lightweight local Kubernetes cluster beforehand to ensure correctness before reaching the cloud environment.

## Development → Production Flow

To perform safe and iterative testing, Minikube is used as the first step of the deployment workflow. It provides a full Kubernetes cluster inside a single virtual machine, making it ideal for rapid experimentation, debugging, and early validation of deployments and service behavior.

In this project, Minikube runs directly on an EC2 instance. Since the instance itself is already virtualized, no additional hypervisor is required. This setup enables testing Kubernetes components in a controlled, cloud-based environment without the overhead provisioning multiple EC2 instances to form a multi-node cluster — something only necessary once transitioning to EKS.

## Demo Application Overview

This repository contains a lightweight demo application used to practice Kubernetes concepts in a realistic, multi-component environment.

The application consists of three parts deployment — a Frontend, a Redis Leader, and a Redis Follower — which provides a practical scenario for exploring deployments, services, DNS-based communication, and testing multi-pod interactions.

The goal here is not to develop or enhance the application itself. Instead, this project serves as a hands-on learning environment where I experiment with:

- Kubernetes deployments and service exposure

- Internal networking and pod-to-pod communication

- Port testing and connectivity validation

- Development-to-production workflow simulation

This setup gives us a structure that resembles a production environment while keeping everything lightweight and easy to reproduce.

For details on how this application is deployed in a cloud-aligned development environment, including Minikube inside EC2 and subsequent validation before moving to AWS EKS, see the deployment guide:

👉 docs/deployment.md

---
This repository is organized into separate guides to keep the workflow clear and structured:

- **(Dev) Environment Setup (EC2, Docker, Kubectl, Minikube)**
  👉 [docs/01-environment-setup.md](docs/01-environment-setup.md)
  
- **(Dev) Demo Application Deployment (Redis + Dashboard)**
  👉 [docs/02-demo-app-deploy.md](docs/02-demo-app-deploy.md)
  
- **(Prod)  Accessing Amazon EKS cluster from a local machine.**
  👉 [docs/03-enviroment-setup-eks.md](docs/03-enviroment-setup-eks.md)
  
- **(Prod) Accessing Amazon EKS cluster from a local machine.**
  👉 [docs/04-EKS operation.md](docs/04-EKS-operation.md)
  
- **(Prod) Guide to delete EKS AWS cluster and all its components**
👉 [docs/05-Removing AWs Components.md](docs/05-Removing-AWs-Components.md)




