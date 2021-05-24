#!/bin/bash

AWS_REGION="us-east-1"
CLUSTER_NAME="Cluster-TF"

TASK_ARN=$(aws ecs list-tasks \
    --cluster $CLUSTER_NAME \
    --query 'taskArns[0]' \
    --output text \
    --region $AWS_REGION)

ENI_ARN=$(aws ecs describe-tasks \
    --cluster $CLUSTER_NAME \
    --tasks $TASK_ARN \
    --query 'tasks[0].attachments[0].details[1].value' \
    --output text \
    --region $AWS_REGION)

PUBLIC_IP=$(aws ec2 describe-network-interfaces \
    --network-interface-ids $ENI_ARN \
    --query 'NetworkInterfaces[0].Association.PublicIp' \
    --output text \
    --region $AWS_REGION)

echo "Your Public IP is: ${PUBLIC_IP}"

