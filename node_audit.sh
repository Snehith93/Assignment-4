#!/bin/bash

# Simple EKS Node Health Audit Script

AMI_MAX_AGE_DAYS=30

if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found"; exit 1
fi
if ! command -v aws &> /dev/null; then
    echo "aws CLI not found"; exit 1
fi

echo -e "NODE NAME\t\tSTATUS\t\tAMI AGE (DAYS)"

kubectl get nodes --no-headers -o custom-columns=NAME:.metadata.name,READY:.status.conditions[?(@.type==\"Ready\")].status | \
while read -r NODE_NAME READY_STATUS; do
    [ -z "$NODE_NAME" ] && continue
    STATUS="NotReady"
    [ "$READY_STATUS" = "True" ] && STATUS="Ready"

    INSTANCE_ID=$(kubectl get node "$NODE_NAME" -o jsonpath='{.spec.providerID}' 2>/dev/null | awk -F/ '{print $NF}')
    [ -z "$INSTANCE_ID" ] && { echo -e "$NODE_NAME\t$STATUS\t\tUNKNOWN"; continue; }

    AMI_ID=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].ImageId" --output text 2>/dev/null)
    [ -z "$AMI_ID" ] && { echo -e "$NODE_NAME\t$STATUS\t\tUNKNOWN"; continue; }

    CREATION_DATE=$(aws ec2 describe-images --image-ids "$AMI_ID" --query "Images[0].CreationDate" --output text 2>/dev/null)
    [ -z "$CREATION_DATE" ] && { echo -e "$NODE_NAME\t$STATUS\t\tUNKNOWN"; continue; }

    NOW=$(date +%s)
    if [ "$(uname)" = "Darwin" ]; then
        CREATED=$(date -j -f "%Y-%m-%dT%H:%M:%S.%3NZ" "$CREATION_DATE" "+%s")
    else
        CREATED=$(date -d "$CREATION_DATE" +%s)
    fi
    AGE=$(( (NOW - CREATED) / 86400 ))
    AGE_DISPLAY="$AGE"
    [ "$AGE" -gt "$AMI_MAX_AGE_DAYS" ] && AGE_DISPLAY="$AGE (OLD)"

    echo -e "$NODE_NAME\t$STATUS\t\t$AGE_DISPLAY"
done