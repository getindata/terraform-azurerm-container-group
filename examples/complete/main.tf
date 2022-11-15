module "resource_group" {
  source  = "github.com/getindata/terraform-azurerm-resource-group?ref=v1.2.0"
  context = module.this.context

  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source              = "github.com/Azure/terraform-azurerm-vnet?ref=3.0.0"
  resource_group_name = module.resource_group.name
  vnet_location       = module.resource_group.location
  subnet_delegation = {
    subnet1 = {
      containers = {
        service_name    = "Microsoft.ContainerInstance/containerGroups"
        service_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = module.this.id
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tags                = module.this.tags
  sku                 = "PerGB2018"
}

module "full_example" {
  source  = "../../"
  context = module.this.context

  name                = "nginx"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  subnet_ids = [module.vnet.vnet_subnets[0]]

  containers = {
    nginx = {
      image  = "nginx:latest"
      cpu    = 1
      memory = 2
      ports = [
        {
          port = 80
        }
      ]
      environment_variables = {
        FOO = "bar"
      }
      secure_environment_variables = {
        SECRET_FOO = "secret-bar"
      }
      volumes = {
        nginx-html = {
          mount_path = "/usr/share/nginx/html"
          secret = {
            "index.html" = base64encode("<h1>Hello World</h1>")
          }
        }
      }
    }
  }

  identity = {
    system_assigned_identity_role_assignments = [{
      scope                = module.resource_group.id
      role_definition_name = "Contributor"
    }]
  }

  container_diagnostics_log_analytics = {
    workspace_id  = azurerm_log_analytics_workspace.this.workspace_id
    workspace_key = azurerm_log_analytics_workspace.this.primary_shared_key
  }

  container_group_diagnostics_setting = {
    workspace_resource_id = azurerm_log_analytics_workspace.this.id
  }
}
