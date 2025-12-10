# Local Enviroment Setup

## Minikube: Local vs Virtual
When running Minikube on a local machine, a virtualization layer is required—typically something like VirtualBox. However, when using a virtualized environment such as an EC2 instance, an additional hypervisor is not needed, because the instance already provides the underlying virtualization required for Minikube's nodes.

## overview : 
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
minikube status
```

Always start Minikube without sudo. Running it with elevated privileges causes configuration files to be created under /root, leading to permission issues and extra steps to fix them.

 --driver= None  must NOT be used in production !!! 
This mode is intended exclusively for testing, development, or learning environments. In this configuration, Kubernetes components run directly on the host with elevated privileges, which can introduce security and stability risks.

3️⃣ Test minikube :
Create a Deployment and a NodePort Service to expose the application outside the cluster.
```bash
kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
kubectl expose deployment hello-minikube --type=NodePort --port=80 --node-port=30080  # Open port 80 on container and port 30080 on all nodes 

kubectl port-forward service/hello-minikube 7080:80 # creates forwarding from local host machine to the service inside the cluster
#http://localhost:7080/
```

## 🖥️ Configure AWS Security group
Create a security group on aws with  same port on the above command "--node-port=30080" :
- Custom TCP rule
- port range = 30080
- Source = My IP

Associate it to the EC2: Actions > Networking > change security group

Acess EC2 on the browser: 

```<instance-public-dns-adress>:30080```
