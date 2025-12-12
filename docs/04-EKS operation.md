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



## deploy APP

```
