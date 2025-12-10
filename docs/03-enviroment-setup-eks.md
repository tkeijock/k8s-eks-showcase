#  Context
This document is part of a multi-file repository. Earlier steps used Minikube on EC2; this section focuses on accessing an Amazon EKS cluster from a local machine.

# EKS Local Access – Technical Overview

This section demonstrates how to access and manage an Amazon EKS cluster from a local Linux machine using IAM-based authentication.

Key concepts covered:

- Local Linux environment prepared for Kubernetes

- AWS CLI and kubectl installed and compatible

- IAM roles and policies for EKS access

- Dedicated VPC provisioned before cluster creation

- EKS cluster created via AWS CLI

- kubeconfig generation for remote access

- IAM → token → EKS API authentication flow

---

#  EKS Prerequisites:

### 1️⃣ Local machine:
It can be any Linux distribution. You can check it with:
```
lsb_release -a   # works on Ubuntu/Debian to show distro and version
cat /etc/os-release  # works on most Linux distros
```

In this example, I used: Ubuntu 18.04.01 LTS

### 2️⃣ AWS CLI Updated 

[AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

Check your version with:

```bash aws --version  ``` 

 The AWS CLI must be at version ≥ 1.17.9 (latest version recommended) to ensure full official support for EKS commands (```aws eks ...```). 

Note: Version 1.16.73 introduced the initial EKS-related commands, but 1.17.9 includes broader functionality and improved command coverage.

### 3️⃣ Kubectl updated

Check your version with:
```bash kubectl version ```

Using a compatible kubectl version is important to avoid “version skew” issues. 
While AWS does not require an exact version match, the official EKS documentation recommends keeping ```kubectl``` within the same minor version as the k8s cluster — or at most one minor version above or below.

For example, if the EKS cluster is running Kubernetes 1.32, the recommended kubectl versions are 1.32, 1.31, or 1.33. 
As a best practice, you should always update kubectl whenever you upgrade your EKS cluster to ensure full compatibility with the Kubernetes API.

Check kubernetes version : [AWS list with Kubernetes versions](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html)

Refer to the previous steps to [Install Local kubectl](https://github.com/tkeijock/k8s-eks-showcase/blob/main/docs/01-environment-setup.md#%EF%B8%8F-install-kubectl) 


# EKS initialization

### 1️⃣ IAM 
AWS IAM (Identity and Acess Management) configuration is required because EKS relies entirely on IAM roles and policies to authorize cluster creation and API access.

Creating a Role : Role > Create a Role > EKS

Required Policies: 

- AmazonEKSClusterPolicy

- AmazonEKSServicePolicy

### 2️⃣ Cloud formation 

An Amazon EKS cluster requires a VPC as its underlying networking layer, and  EKS does not create networking resources by default; a VPC must exist beforehand. Also, AWS recommends using a dedicated VPC for EKS to ensure proper isolation and predictable networking behavior.

To simplify and standardize this setup, AWS CloudFormation is used to provision the VPC and its associated resources through infrastructure-as-code templates.

Cloud formation just need the template file that can be found here: 
[AWS CloudFormation creating VPC with Templates (Official Links)](https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html)

I used this template: [IPv4 VPC template](https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml)

Create the VPC with a name and save it. ex: **VPC-K8S**

### 3️⃣ Creating EKS cluster

Creating an EKS cluster via the AWS Management Console (UI) requires an IAM user and may enforce MFA (Multi-Factor Authentication) depending on account policies. If MFA wasn’t properly configured or my account had strict IAM policies, certain actions—like creating a cluster—could fail due to insufficient permissions or missing MFA tokens. Using the AWS CLI allowed me to leverage configured profiles or temporary credentials, bypassing some of these issues and enabling smoother automation.

To create the cluster, I needed the Amazon Resource Name ( ARN) of the IAM role I created, which is the globally unique identifier of the role in AWS. Additionally, I had to define the VPC resources using the VPC name and subnets. 

To simplify the cluster creation, I created a separate script that fetches the necessary VPC, subnet, and security group IDs. You can find it in this repository: [eks-vpc-subnets-setup.sh](https://github.com/tkeijock/k8s-eks-showcase/blob/main/k8s%20/eks-vpc-subnets-setup.sh).

The script exports the following variables that we will use in the `aws eks create-cluster` command:

- `VPC_ID` – the ID of the VPC
- `PUBLIC_SUBNETS` – an array of public subnet IDs
- `PRIVATE_SUBNETS` – an array of private subnet IDs
- `subnetIds` – a comma-separated string of all subnet IDs
- `SECURITY_GROUP` – the default security group ID for the VPC

 Cluster creation command:

```
aws eks create-cluster \
  --name my-cluster \
  --role-arn $ROLE_ARN \
  --resources-vpc-config subnetIds=$subnetIds,securityGroupIds=$SECURITY_GROUP
```
### Note about region and Kubernetes version

- **Region**: If you don't pass `--region`, the AWS CLI uses the region configured in the default profile (`~/.aws/config`).  
  Check with: `aws configure list`

- **Kubernetes version**: If you don't pass `--kubernetes-version`, EKS creates the cluster using the latest default version available in AWS.  
  To see the available versions: `aws eks list-kubernetes-versions --region <your-region>`

it can take around 12 ~ 15 min to create a cluster.


### 4️⃣ Check cluster status

After creating the cluster, verify that it is active:

```
aws eks list-clusters
aws eks describe-cluster --name my-cluster | grep status
```
Proceed only when the cluster status is ACTIVE.

5️⃣ Configure local Kubectl (one-time setup)

Once the cluster is active, configure local access for kubectl:

```aws eks update-kubeconfig --name <cluster-name>```

This command creates the pointer between  kubectl and the cluster. 
in practical terms, it updates the local kubeconfig file (~/.kube/config) with  EKS API endpoint, the cluster CA certificate and authentication method based on AWS IAM.

⚠️ This command does not authenticate to the cluster. It only  updates the local kubeconfig file so that ```kubectl``` can connect to the EKS cluster.

> NOTE: Each time you run a `kubectl` command (for example, `kubectl get nodes`), Kubernetes automatically invokes `aws eks get-token`.  
The AWS CLI then uses local IAM credentials to generate a temporary authentication token, which is used to securely authenticate the request against the EKS API server.

6️⃣ Check Kubectl
use on the local machine : 
```kubectl get nodes  ``` 

# EKS Remote control

EKS access from a local machine is entirely based on IAM authentication.
In modern environments, the AWS CLI is the recommended mechanism, as it natively generates authentication tokens via "aws eks get-token".

Historically, this functionality was provided by the standalone ```aws-iam-authenticator``` binary.

Both approaches use the same mechanism: local IAM credentials are exchanged for a temporary token to authenticate against the EKS API server.


### aws-iam-authenticator details

For compatibility with legacy clusters and existing automation, this repository also provides an optional script to install and configure ```aws-iam-authenticator```:

[iam-authenticator-install.sh](https://github.com/tkeijock/k8s-eks-showcase/blob/main/scripts/iam-authenticator-install.sh)

[AWS IAM Authenticator Github Repository](https://github.com/kubernetes-sigs/aws-iam-authenticator)

[AWS  EKS setup with instructions to setup IAM Authenticator](https://docs.aws.amazon.com/deep-learning-containers/latest/devguide/deep-learning-containers-eks-setup.html)




