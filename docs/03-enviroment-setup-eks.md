In the development environment, I used a single EC2 instance to run a Minikube cluster.
Now, I will use my local machine to connect publicly to the EKS cluster.

Before proceeding, it is required to check a few prerequisites:

### 1️⃣ Local machine:
it can be any distribution  you can check with : 
```
lsb_release -a   # works on Ubuntu/Debian to show distro and version
cat /etc/os-release  # works on most Linux distros
```

in this example i used: Ubuntu 18.04.01 LTS

### 2️⃣ AWS CLI Updated 

Installation guide: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Check your version with:

```bash aws --version  ``` 

 The AWS CLI must be at version ≥ 1.17.9 (latest version recommended) to ensure full official support for EKS commands (```aws eks ...```). 

Note: Version 1.16.73 introduced the initial EKS-related commands, but 1.17.9 includes broader functionality and improved command coverage.

### 3️⃣ Kubectl updated

Check your version with:
```bash kubectl version ```

Using a compatible kubectl version is important to avoid “version skew” issues. 
While AWS does not require an exact version match, the official EKS documentation recommends keeping kubectl within the same minor version as the cluster — or at most one minor version above or below.

For example, if the EKS cluster is running Kubernetes 1.32, the recommended kubectl versions are 1.32, 1.31, or 1.33. 
As a best practice, you should always update kubectl whenever you upgrade your EKS cluster to ensure full compatibility with the Kubernetes API.

consult eks versions on : https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html


# EKS initialization

## 1️⃣ IAM 

First it is requried to use AWS IAM (Identity and Acess Management) to permite manage the EKS service. 

Creating a Role : Role > Create a Role > EKS

Required Policies: 

- AmazonEKSClusterPolicy

- AmazonEKSServicePolicy


## 2️⃣ Cloud formation 

An Amazon EKS cluster requires a VPC as its underlying networking layer, and AWS recommends using a dedicated VPC for EKS to ensure proper isolation and predictable networking behavior. To simplify and standardize this setup, AWS CloudFormation is used to provision the VPC and its associated resources through infrastructure-as-code templates.

Cloud formation just need the template file that can be found here: 

[AWS CloudFormation creating VPC with Templates (Official Links)](https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html)

I used this template: [IPv4 VPC template](https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml)

Create the VPC with a name and save it. ex: **VPC-K8S**

## 3️⃣ Creating EKS cluster

Creating an EKS cluster via the AWS Management Console (UI) requires an IAM user and may enforce MFA (Multi-Factor Authentication) depending on account policies. If MFA wasn’t properly configured or my account had strict IAM policies, certain actions—like creating a cluster—could fail due to insufficient permissions or missing MFA tokens. Using the AWS CLI allowed me to leverage configured profiles or temporary credentials, bypassing some of these issues and enabling smoother automation.

To create the cluster, I needed the Amazon Resource Name ( ARN) of the IAM role I created, which is the globally unique identifier of the role in AWS. Additionally, I had to define the VPC resources using the VPC name and subnets. 

To simplify the cluster creation, I created a separate script that fetches the necessary VPC, subnet, and security group IDs. You can find it in this repository: [eks-vpc-subnets-setup.sh](https://github.com/tkeijock/k8s-eks-showcase/blob/main/k8s%20/eks-vpc-subnets-setup.sh).

The script exports the following variables that we will use in the `aws eks create-cluster` command:

- `VPC_ID` – the ID of the VPC
- `PUBLIC_SUBNETS` – an array of public subnet IDs
- `PRIVATE_SUBNETS` – an array of private subnet IDs
- `subnetIds` – a comma-separated string of all subnet IDs
- `SECURITY_GROUP` – the default security group ID for the VPC

The script exports the following variables that we will use in the `aws eks create-cluster` command:

Create-cluster command:
```
aws eks create-cluster --name my-cluster --role-arn $ROLE_ARN --resources-vpc-config subnetIds=$subnetIds, securityGroupIds=$SECURITY_GROUP
```
### Note about region and Kubernetes version

- **Region**: If you don't pass `--region`, the AWS CLI uses the region configured in the default profile (`~/.aws/config`).  
  Check with: `aws configure list`

- **Kubernetes version**: If you don't pass `--kubernetes-version`, EKS creates the cluster using the latest default version available in AWS.  
  To see the available versions: `aws eks list-kubernetes-versions --region <your-region>`

it can take around 12 ~ 15 min to create a cluster.


## 4  Checking cluster 
usefull commands

```
aws eks list-cluster
aws eks describe-cluster --name my-cluster | grep status
```

# EKS Operation

To interact with the EKS cluster from my local machine, I used the AWS IAM Authenticator. This tool allows kubectl to authenticate with the cluster using IAM credentials, ensuring that access is securely managed according to the IAM roles and policies I configured. With the authenticator, I can run Kubernetes commands locally without needing static kubeconfig certificates, and the permissions are automatically aligned with the IAM role associated with my user or session.

 [AWS IAM Authenticator Github Repository](https://github.com/kubernetes-sigs/aws-iam-authenticator)
 [AWS instructions on how to use IAM Authenticator](https://docs.aws.amazon.com/deep-learning-containers/latest/devguide/deep-learning-containers-eks-setup.html)

 ```
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH
```
