data "azurerm_client_config" "current" {}

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

module "key_vault" {
  source  = "github.com/getindata/terraform-azurerm-keyvault?ref=v1.0.0"
  context = module.this.context

  sku_name            = "standard"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

  rbac_authorization_enabled = true
}

resource "azurerm_role_assignment" "current" {
  principal_id = data.azurerm_client_config.current.object_id
  scope        = module.key_vault.key_vault_id

  role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_key_vault_secret" "baz" {
  key_vault_id    = module.key_vault.key_vault_id
  name            = "baz"
  value           = "secret-baz"
  expiration_date = "2023-12-30T20:00:00Z"
  content_type    = "Some secret"

  depends_on = [azurerm_role_assignment.current]
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
      secure_environment_variables_from_key_vault = {
        SECRET_BAZ = {
          key_vault_id = module.key_vault.key_vault_id
          name         = "baz"
        }
      }
      volumes = {
        nginx-html = {
          mount_path = "/usr/share/nginx/html"
          secret = {
            "index.html" = base64encode("<h1>Hello World</h1>")
          }
        }
        secrets = {
          mount_path = "/etc/secrets"
          secret = {
            "username" = base64encode("foobar")
          }
          secret_from_key_vault = {
            secret-baz = {
              key_vault_id = module.key_vault.key_vault_id
              name         = "baz"
            }
          }
        }
      }
    }
  }

  exposed_ports = [
    {
      port = 80
    }
  ]

  restart_policy = "Always"

  identity = {
    enabled = true
    user_assigned_identity = {
      enabled = true
    }
    role_assignments = [{
      scope                = module.resource_group.id
      role_definition_name = "Contributor"
    }]
  }

  container_diagnostics_log_analytics = {
    workspace_id  = azurerm_log_analytics_workspace.this.workspace_id
    workspace_key = azurerm_log_analytics_workspace.this.primary_shared_key
  }

  diagnostic_settings = {
    enabled               = true
    logs_destinations_ids = [azurerm_log_analytics_workspace.this.id]
  }

  depends_on = [azurerm_key_vault_secret.baz] #Let's wait until secret is created, so we can reference it by name
}
