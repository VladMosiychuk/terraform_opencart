#!/bin/sh

AWS_REGION="us-east-1"

OC_VER="0.1"
OC_REP="opencart"

MS_VER="0.1"
MS_REP="mymysql"

# Get Account ID
ACCOUNT_ID=$(aws sts get-caller-identity \
    --query "Account" \
    --output text)

# Create image repository for Opencart
aws ecr create-repository \
    --repository-name $OC_REP \
    --image-scanning-configuration scanOnPush=true \
    --region $AWS_REGION

# Create image repository for MySQL
aws ecr create-repository \
    --repository-name $MS_REP \
    --image-scanning-configuration scanOnPush=true \
    --region $AWS_REGION

# Create registry url
REGISTRY_URL="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Authenticate local Docker CLI into ECR
aws ecr get-login-password \
    --region $AWS_REGION | \
    docker login \
        --username AWS \
        --password-stdin $REGISTRY_URL

# Tag images to point to corresponding repositories
docker tag "$OC_REP:$OC_VER" $REGISTRY_URL/$OC_REP:$OC_VER
docker tag "$MS_REP:$MS_VER" $REGISTRY_URL/$MS_REP:$MS_VER

# Push images to ECR repository
docker push "$REGISTRY_URL/$OC_REP:$OC_VER"
docker push "$REGISTRY_URL/$MS_REP:$MS_VER"

# Create cloud destructor
echo "#!/bin/bash

# Delete image repositories
aws ecr delete-repository --repository-name $OC_REP --region $AWS_REGION --force
aws ecr delete-repository --repository-name $MS_REP --region $AWS_REGION --force

# Log out from registry
docker logout $REGISTRY_URL
" > "destructor.sh"

# Make destructor executable
chmod +x destructor.sh