#!/bin/bash

# =========================================
# Node Group Creation Script for EKS
# =========================================
# Fully dynamic for VPC, subnets, and default security group.
# You provide VPC_NAME and CLUSTER_NAME name manually.
# =========================================
  
# --- CloudFormation Template URL for Node Group ---
TEMPLATE_URL="https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2018-12-10/amazon-eks-nodegroup.yaml"
  
# --- Main Configuration Variables ---
VPC_NAME="VPC-K8S"                    # VPC Tag NAME
CLUSTER_NAME="my-cluster"             # EKS cluster name  
KEY_NAME="my-keypair"                 # EC2 KeyPair name to access nodes

## --- Other Configuration Variables ---
STACK_NAME="my-eks-nodegroup"         # CloudFormation stack name for the node group
NODE_GROUP_NAME="my-nodegroup"        # Node group name
INSTANCE_TYPE="t3.small"              # Force t3.small even if YAML default differs
NODE_IMAGE_ID="ami-0440e4f6b9713faf6" # Specific AMI to use on EKS nodes
MIN_SIZE=1
DESIRED_SIZE=3
MAX_SIZE=4

## --- Scripted Configuration Variables ---
#VPC_ID=script by tag name            # VPC ID
#SUBNET_IDS=script                    # Comma-separated list of public + private subnets
#SECURITY_GROUP=script                # Default security group ID for the VPC

# --- Get VPC ID by the tag name --- 
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=$VPC_NAME" \
    --query "Vpcs[0].VpcId" \
    --output text)
  
# --- Get all subnets for the VPC ---
PUBLIC_SUBNETS=($(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Public,Values=true" \
    --query "Subnets[*].SubnetId" \
    --output text))

PRIVATE_SUBNETS=($(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Private,Values=true" \
    --query "Subnets[*].SubnetId" \
    --output text))
  
# Join all subnets into a comma-separated list
SUBNET_IDS=$(IFS=,; echo "${PUBLIC_SUBNETS[*]},${PRIVATE_SUBNETS[*]}")

# --- Get default security group for the VPC ---
SECURITY_GROUP=$(aws ec2 describe-security-groups \
    --filters Name=vpc-id,Values=$VPC_ID Name=group-name,Values=default \
    --query "SecurityGroups[0].GroupId" --output text)


# --- Create the Node Group Stack ---
aws cloudformation create-stack \
  --stack-name "$STACK_NAME" \
  --template-url "$TEMPLATE_URL" \
  --capabilities CAPABILITY_IAM \
  --parameters \
    ParameterKey=ClusterName,ParameterValue="$CLUSTER_NAME" \
    ParameterKey=NodeGroupName,ParameterValue="$NODE_GROUP_NAME" \
    ParameterKey=NodeAutoScalingGroupMinSize,ParameterValue=$MIN_SIZE \
    ParameterKey=NodeAutoScalingGroupDesiredSize,ParameterValue=$DESIRED_SIZE \
    ParameterKey=NodeAutoScalingGroupMaxSize,ParameterValue=$MAX_SIZE \
    ParameterKey=NodeInstanceType,ParameterValue="$INSTANCE_TYPE" \
    ParameterKey=NodeImageId,ParameterValue="$NODE_IMAGE_ID" \
    ParameterKey=KeyName,ParameterValue="$KEY_NAME" \
    ParameterKey=NodeGroupSecurityGroup,ParameterValue="$SECURITY_GROUP" \
    ParameterKey=VpcId,ParameterValue="$VPC_ID" \
    ParameterKey=Subnets,ParameterValue="$SUBNET_IDS"

echo "Node group stack $STACK_NAME is being created."
echo "Check status with:"
echo "aws cloudformation describe-stacks --stack-name $STACK_NAME"
