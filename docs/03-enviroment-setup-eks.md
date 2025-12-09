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


## EKS 

1️⃣ IAM 

First it is requried to use AWS IAM (Identity and Acess Management) to permite manage teh EKS service. 

Creating a Role : Role > Create a Role > EKS

Required Policies: 

- AmazonEKSClusterPolicy

- AmazonEKSServicePolicy


2️⃣ Cloud formation 

An Amazon EKS cluster requires a VPC as its underlying networking layer, and AWS recommends using a dedicated VPC for EKS to ensure proper isolation and predictable networking behavior. To simplify and standardize this setup, AWS CloudFormation is used to provision the VPC and its associated resources through infrastructure-as-code templates.

Cloud formation just need the template file that can be found here: 

[AWS CloudFormation creating VPC with Templates (Official Links)](https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html)

I used this template: [IPv4 VPC template](https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml)


3️⃣ 
