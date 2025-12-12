# EKS operation

## Create Node group

AWS provides a template to create nodegroup with cloud formation:

[AWS Cloud formation Template for NodeGroup Yaml](https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2018-12-10/amazon-eks-nodegroup.yaml)

Based on this yaml template i created a script using AWS CLI:

[My Script to create Node Group for EKS](https://github.com/tkeijock/k8s-eks-showcase/blob/main/scripts/eks-create-nodegroup-cf.sh)

Instead of checking VPC IDs, subnets, security groups, and other parameters by hand, 
the script dynamically discovers all required resources based solely on the VPC name and injects them into the official EKS NodeGroup CloudFormation template. 
This removes repetitive UI steps, avoids human error, and drastically speeds up cluster setup 
— turning a multi-step console-driven task into a single reliable command.

Important variables and their default values: 

```bash
VPC_NAME="VPC-K8S"                   
CLUSTER_NAME="my-cluster"             
KEY_NAME="my-keypair"                 # EC2 KeyPair name to access nodes

## --- Other Configuration Variables ---
STACK_NAME="my-eks-nodegroup"         
NODE_GROUP_NAME="my-nodegroup"       
```

## Add Nodes to cluster using Kubectl

Amazon EKS uses a ConfigMap called `aws-auth` in the `kube-system` namespace to map IAM roles and users to Kubernetes RBAC identities.  
This allows nodes and IAM principals to authenticate and interact with the cluster.

For official guidance on how to edit and manage this ConfigMap, see the AWS EKS User Guide:
[Offical Guide](https://docs.aws.amazon.com/eks/latest/userguide/auth-configmap.html)

In this template
[Oficial Template Yaml: Requires manual change to ARN variable](https://github.com/tkeijock/k8s-eks-showcase/blob/main/scripts/cm-aws-auth)

Based on teh above template, i created a script using AWS CLI to apply  ``` aws-auth```:

[My script to apply ``` aws-auth```](https://github.com/tkeijock/k8s-eks-showcase/blob/main/scripts/eks-apply-node-authorizer.sh)
>The Script in the end apply ``` kubectl apply -f aws-auth-cm.yaml ```

This script automates the process of creating the necessary ``` aws-auth``` ConfigMap for your Amazon EKS cluster, 
which is required to associate your worker nodes with the cluster. 
Instead of manually retrieving the Node Instance Role ARN and configuring the aws-auth file, the script **dynamically fetches the ARN**, 
injects it into the aws-auth ConfigMap template, and applies it to your cluster using kubectl. This saves time and reduces the chances of error, 
automating a crucial step that would otherwise require manual intervention through the AWS Management Console and kubectl commands.

## APP on EKS
Intially the Dev enviroment was configured only one instance with minikube to provide a cluster, now on EKS running on multiple instances it is important to use a Loadbalancer in the cloud to distribute the traffic.

to achive this, yaml file [service-fronted-eks.yaml](https://github.com/tkeijock/k8s-eks-showcase/blob/main/k8s/service-fronted-eks.yaml) 
uses the parameter ``` type: LoadBalancer ```, instead of ```Nodeport``` that was used in the Development enviroment.

When you create a Kubernetes Service of type LoadBalancer, Kubernetes delegates the creation of the external load balancer to the cloud provider. Internally, the cluster first provisions the equivalente of a NodePort service, and then the cloud-controller-manager uses the cloud API to configures an external load balancer (in the cloud) that forwards traffic to that node port. 

In Amazon EKS, the AWS cloud-controller-manager automatically provisions an external load balancer fully managed by AWS called ``` AWS-managed Load Balancer ```, assigns it a public IP or DNS name, and updates the Service’s .status.loadBalancer field asynchronously as the resource becomes available. All external traffic is routed through this AWS Load Balancer to the worker nodes and then to the application Pods, allowing the application to be accessed directly through a fully managed, cloud-native entry point.

### Deploy APP
As mentioned above, the Service with loadbalancer is used. All the other Deployment and Service yamls are the same from the Dev enviroment and can be found in the repository. Here is the script to apply all of them with kubectl:

[APP deploy with modified Service load balancer](https://raw.githubusercontent.com/tkeijock/k8s-eks-showcase/refs/heads/main/scripts/eks-deploy-guestbook.sh)
 
on the local machine use:

``` 
curl -O https://raw.githubusercontent.com/tkeijock/k8s-eks-showcase/refs/heads/main/scripts/eks-deploy-guestbook.sh
chmod +x eks-deploy-guestbook.sh
./eks-deploy-guestbook.sh
```
this uses kubectl apply on Deployments and Services yamls

Get DNS public IP adress :
``` kubectl get svc frontend -o wide ```

## Scale
test scale
``` kubectl scale deploy frontend -- replicas=5 ```

## Monitoring 

Deploy the web UI (Kubernetes Dashboard):
[Dashboard APP : Oficial Kubernetes Guide](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

the oficial site explicit says that need to use Helm to install the dash board, and this can be done using Helm oficial script and oficial commands to install the dash boar.
commands to update local machine and install Helm:
```
# --- Prepare Ubuntu ---
sudo apt-get update
sudo apt-get install -y curl apt-transport-https

# --- Install Helm 3 using the official script ---
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# --- Add Kubernetes Dashboard Helm repository ---
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update

# --- Deploy Kubernetes Dashboard in its namespace ---
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --create-namespace --namespace kubernetes-dashboard
 ```

Kubectl will make Dashboard available at https://localhost:8443.

### Details 

[Guide: create a sample user](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)
[Create admin-user-role.yaml](https://github.com/tkeijock/k8s-eks-showcase/blob/main/k8s/admin-user-role.yaml)
``` 
kubectl apply -f admin-user-role.yaml
```

get token :

``` 
kubectl -n kubernetes-dashboard create token admin-user
```
