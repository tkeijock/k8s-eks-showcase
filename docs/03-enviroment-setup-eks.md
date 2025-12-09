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

Create the VPC with a name and save it. ex: **VPC-K8S**

3️⃣ EKS cluster

Simple option using UI: Inside EKS service > create EKS cluster 

using two factor authnetication can cause some problems while creating direclty so it is better to use AWS CLI :

The Amazon Resource Name (ARN) from the IAM Role that we created is required to create a clsuter.
The ARN is the globally unique identifier of the IAM role in AWS. Here is saved in the variable ```ROLE_ARN ```.

```
ROLE_ARN=$(aws iam get-role --role-name MyRole --query "Role.Arn" --output text)
```

Then  need to define the VPC resources using the VPC name and subnets.

```
# check VPC ID by the TAG name 
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=VPC-K8S" \
    --query "Vpcs[0].VpcId" \
    --output text)

#echo "VPC ID: $VPC_ID"

# Public Subnets
PUBLIC_SUBNETS=($(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Public,Values=true" \
    --query "Subnets[*].SubnetId" \
    --output text))

# Private Subnets
PRIVATE_SUBNETS=($(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Private,Values=true" \
    --query "Subnets[*].SubnetId" \
    --output text))

# Check subnets
#echo "Public subnets: ${PUBLIC_SUBNETS[@]}"
#echo "Private subnets: ${PRIVATE_SUBNETS[@]}"

# Join All subnets
subnetIds=$(IFS=,; echo "${PUBLIC_SUBNETS[*]},${PRIVATE_SUBNETS[*]}")
#echo $subnetIds

SECURITY_GROUP=$(aws ec2 describe-security-groups \
    --filters Name=vpc-id,Values=$VPC_ID Name=group-name,Values=default \
    --query "SecurityGroups[0].GroupId" --output text)

```

Create cluster command:
```
aws eks create-cluster --name my-cluster --role-arn $ROLE_ARN --resources-vpc-config subnetIds=$subnetIds, securityGroupIds=$SECURITY_GROUP
```
it can take around 12 min to create a cluster.
