#!/bin/bash

# ==============================
#  AWS AUTH CONFIGMAP GENERATOR
# ==============================

# === EDITABLE VARIABLES ===
CLUSTER_NAME="my-cluster"
NODEGROUP_NAME="my-nodegroup"
REGION="us-west-2"
TEMPLATE_URL="https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2018-08-30/aws-auth-cm.yaml"

# === GET NODE INSTANCE ROLE ARN ===
echo "Fetching Node Instance Role ARN..."
ROLE_ARN=$(aws eks describe-nodegroup \
  --cluster-name "$CLUSTER_NAME" \
  --nodegroup-name "$NODEGROUP_NAME" \
  --region "$REGION" \
  --query "nodegroup.nodeRole" \
  --output text)

if [[ -z "$ROLE_ARN" || "$ROLE_ARN" == "None" ]]; then
  echo "ERROR: Could not fetch the Node Instance Role ARN."
  exit 1
fi

echo "Node Role ARN detected:"
echo "$ROLE_ARN"
echo

# === DOWNLOAD TEMPLATE ===
echo "Downloading aws-auth template..."
curl -s -o aws-auth-cm.yaml "$TEMPLATE_URL"

if [[ ! -f aws-auth-cm.yaml ]]; then
  echo "ERROR: Failed to download aws-auth-cm.yaml"
  exit 1
fi

# === INJECT THE ROLE ARN INTO THE TEMPLATE ===
sed -i "s|<ARN of instance role (not instance profile)>|$ROLE_ARN|g" aws-auth-cm.yaml

# === APPLY TO THE CLUSTER ===
echo "Applying aws-auth ConfigMap..."
kubectl apply -f aws-auth-cm.yaml

echo "aws-auth ConfigMap applied successfully."

