namespace           = "getindata"
stage               = "example"
location            = "West Europe"
resource_group_name = "container-group-complete-example"

descriptor_formats = {
  resource-group = {
    labels = ["name"]
    format = "%v-rg"
  }
  azure-container-group = {
    labels = ["namespace", "environment", "stage", "name"]
    format = "%v-%v-%v-%v-aci"
  }
  azure-managed-service-identity = {
    labels = ["namespace", "environment", "stage", "name"]
    format = "%v-%v-%v-%v-msi"
  }
  azure-key-vault = {
    labels = ["namespace", "environment", "stage", "name"]
    format = "%v-%v-%v-%v-kv"
  }
}

tags = {
  Terraform = "True"
}
