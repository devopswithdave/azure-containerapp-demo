resource "azurerm_resource_group" "rg" {
  name     = "${var.app_name}-rg"
  location = var.location
  tags = {
    Environment = var.environment
  }
}

module "loganalytics" {
  source                       = "./modules/log-analytics"
  log_analytics_workspace_name = "${var.app_name}la"
  location                     = var.location
  log_analytics_workspace_sku  = "PerGB2018"
  environment                  = var.environment
  resource_group_name          = azurerm_resource_group.rg.name
}

module "appinsights" {
  source              = "./modules/appinsights"
  name                = "${var.app_name}insights"
  location            = var.location
  environment         = var.environment
  application_type    = "web"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azapi_resource" "containerapp_environment" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = "${var.app_name}acaenv"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = module.loganalytics.workspace_id
          sharedKey  = module.loganalytics.primary_shared_key
        }
      }
    }
  })

  depends_on = [
    azurerm_log_analytics_workspace.Log_Analytics_WorkSpace
 ]
}

resource "azurerm_user_assigned_identity" "containerapp" {
  location            = azurerm_resource_group.rg.location
  name                = "containerappmi"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "containerapp" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "acrpull"
  principal_id         = azurerm_user_assigned_identity.containerapp.principal_id
  depends_on = [
    azurerm_user_assigned_identity.containerapp
  ]
}

resource "azapi_resource" "containerappmi" {
  type      = "Microsoft.App/containerapps@2022-03-01"
  name      = "${var.app_name}containermi"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location


  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapp.id]
  }
  body = jsonencode({

    properties = {
      managedEnvironmentId = azapi_resource.containerapp_environment.id
      configuration = {
        ingress = {
          external : true,
          targetPort : 80
        }
      }
      template = {
        containers = [
          {
            image = "springcommunity/spring-framework-petclinic:latest",
            name  = "democontainerappacracr"
            resources = {
              cpu    = 0.25
              memory = "0.5Gi"
            },
            "probes" : [
              {
                "type" : "Liveness",
                "httpGet" : {
                  "path" : "/",
                  "port" : 80,
                  "scheme" : "HTTP"
                },
                "periodSeconds" : 10
              },
              {
                "type" : "Readiness",
                "httpGet" : {
                  "path" : "/",
                  "port" : 80,
                  "scheme" : "HTTP"
                },
                "periodSeconds" : 10
              },
              {
                "type" : "Startup",
                "httpGet" : {
                  "path" : "/",
                  "port" : 80,
                  "scheme" : "HTTP"
                },
                "periodSeconds" : 10
              }
            ]
          }
        ]
        scale = {
          minReplicas = 0,
          maxReplicas = 2
        }
      }
    }

  })
  ignore_missing_property = true
  depends_on = [
    azapi_resource.containerapp_environment
  ]
}
