# Setup
## Service principal creation

The purpose of service principal creation is to allow authentication from the GitHub Action to your Azure subscription.

## Create service principal

1. Ensure you have ran `az-login`
2. Review [service-principal-create.sh](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/setup/scripts/service-principal-create.sh)
3. Run the script `/setup/scripts/service-principal-create.sh`
4. The script will create:
- A service connection called `dfurmidge-spn`
- Grant contributor access to your subscription for the newly created service connection.
5. Review output of script, it will display values that you will need in the next section. Here is an example output:
```
{
  "clientId": "XXXXXX",
  "clientSecret": "XXXXXX",
  "subscriptionId": "XXXXXX",
  "tenantId": "XXXXXX",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```
6. Reviewing in Azure Portal you will see the newly created service principal
![](images/service-connection-azure.png)

## Configure GitHub Secrets

The purpose of this is to save Service Principal credentials within GitHub Repository as secrets

## Create service principal

1. Within the GitHub repository to where you are going to be running the terraform from, select settings -> secrets
2. Add the 4 secrets from the output of script ran in the `Create service principal` section above

- AZURE_AD_CLIENT_ID – Will be the `clientId` value
- AZURE_AD_CLIENT_SECRET – Will be the `clientSecret` value
- AZURE_AD_TENANT_ID – Will be the `tenantId` value
- AZURE_SUBSCRIPTION_ID – Will be the `subscriptionId` value
- AZURE_CREDENTIALS - Will be whole json output including {}

![](images/repo-secrets.png)

## Azure Terraform Setup

The purpose of this section is to create the location that will store the remote Terraform State file

When deploying Terraform there is a requirement that it must store a state file; this file is used by Terraform to map Azure Resources to your configuration that you want to deploy, keeps track of meta data and can also assist with improving performance for larger Azure Resource deployments.

## Create Blob Storage location for Terraform State file
1. Edit the [variables](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/setup/scripts/create-state-backend.sh#L6-L7)
2. Run the script `/setup/scripts/create-state-backend.sh`
3. The script will create
- Azure Resource Group
- Azure Storage Account
- Azure Blob storage location within Azure Storage Account
4. Successful script run will create a storage account with blob:
![](images/storage-account-creation.png)

## Enable and run GitHub Action

The purpose of this section is to enable and run the GitHub Action to Terraform and Apply the Terraform base.

## Run the GitHub Action
1. You may want to update these terraform variables prior to running the action:
- [app_name](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/infra/base/terraform/variables.tf#L4) - Used as a concat for the various resources, such as resource group name etc
- [location](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/infra/base/terraform/variables.tf#L10) - Location for Azure resources to be deployed
- [environment](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/infra/base/terraform/variables.tf#L16) - A meaningful environment name, I used `production` as default. This variable is used as an Azure tag to reference all resources if needed.
2. Uncomment and merge this [GitHub workflow](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/.github/workflows/create-base-infra.yml)
3. Manually run the workflow, currently it is not automatic. We will enable automatic action during merge at a later stage.
- Select Run workflow and main branch as screenshot shows below:
![](images/run-work-flow.png)
4. When successfully ran you can view each of the GitHub Action stages as below screenshot shows output from `Terraform Plan Base` stage:
![](images/terraform-plan-base-stage.png)
5. Reviewing in Azure Portal, you will see the terraform base resources deployed successfully.
![](images/azure-portal-resources.png)

## ACR GitHub Secrets

To allow the GitHub action to successfully Build and deploy the image to the Azure Container Registry, we need to add additional GitHub repository secrets.

## Update GitHub repository secrets with ACR credentials

1. Select Azure Container Registry which you created -> Access Keys tab within settings
![](images/acr-access-keys.png)

2. Add 3 secrets as below from the access keys tab:
- REGISTRY_LOGIN_SERVER - Login server
- REGISTRY_USERNAME - Username
- REGISTRY_PASSWORD - Password

## Update application source code with Application Insights Key

We want to view application insights data from within the application. In this lab, we will add the relevant key to the source code.

## Update source code with Application Insights Key

1. The source code for the sample application is [here](https://github.com/devopswithdave/azure-containerapp-demo/tree/main/aspnet-core-dotnet-core)

2. Update [appsettings.json](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/aspnet-core-dotnet-core/appsettings.json#LL8-L10C4) with Instrumentation key, found by selecting your application insights resource within Azure portal ->  configure -> properities

## Configure GitHub Action to create Azure Container App

The purpose of this section is to enable and run the GitHub Action to Terraform and Apply the Azure Container environment and App.

## Run the GitHub Action
1. You may want to update these terraform variables prior to running the action:
- [app_name](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/infra/aca/terraform/variables.tf#L4) - Used as a concat for the various resources, such as resource group name etc
- [location](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/infra/aca/terraform/variables.tf#L10) - Location for Azure resources to be deployed
- [environment](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/infra/aca/terraform/variables.tf#L16) - A meaningful environment name, I used `production` as default. This variable is used as an Azure tag to reference all resources if needed.

4. Manually run the [workflow](https://github.com/devopswithdave/azure-containerapp-demo/blob/main/.github/workflows/main.yml), currently it is not automatic. We will enable automatic action during merge at a later stage.
- Select Run workflow and main branch as screenshot shows below:
![](images/run-work-flow.png)

5. When successfully ran you can view each of the GitHub Action stages as below screenshot shows pipeline ran successfully with the newly created stages added:
![](images/run-work-flow-finish.png)

6. Reviewing in Azure Portal, you will see the terraform base resources deployed successfully.
![](images/azure-portal-resources.png)

7. Access the application URL from within Azure Portal of Container Application:
![](images/container-app-url.png)

8. With a successfully deploy container app, URL will be accessible as below:
![](images/website-load.png)