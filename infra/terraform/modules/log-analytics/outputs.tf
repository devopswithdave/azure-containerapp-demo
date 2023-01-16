output "workspace_id" {
  value       = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.workspace_id
  description = "customerId"
}

output "primary_shared_key" {
  value       = azurerm_log_analytics_workspace.Log_Analytics_WorkSpace.primary_shared_key
  description = ".primary_shared_key"
}
 