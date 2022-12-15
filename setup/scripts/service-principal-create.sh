#!/usr/bin/env bash
#set -x

# Creates service principal with contributor role in your subscription

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SP_NAME="dfurmidge-spn" # rename this to soemthing else
export MSYS_NO_PATHCONV=1
az ad sp create-for-rbac --name $SP_NAME --role "contributor" --scopes "/subscriptions/$SUBSCRIPTION_ID" --sdk-auth  --output json
servicePrincipalAppId=$(az ad sp list --display-name $SP_NAME --query "[].appId" -o tsv)
az role assignment create --assignee $servicePrincipalAppId --role "User Access Administrator" --scope "/subscriptions/$SUBSCRIPTION_ID"

