# Complete Example

```terraform
module "resource_group" {
  source  = "github.com/getindata/terraform-azurerm-resource-group?ref=v1.2.0"
  context = module.this.context

  name     = var.resource_group_name
  location = var.location
}

module "simple_example" {
  source  = "../../"
  context = module.this.context

  name                = "nginx"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location

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
}
```

## Usage

```
terraform init
terraform plan -var-file fixtures.west-europe.tfvars -out tf.plan
terraform apply tf.plan
```