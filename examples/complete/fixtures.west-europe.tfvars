namespace           = "getindata"
stage               = "example"
location            = "West Europe"
resource_group_name = "container-group-complete-example"

descriptor_formats = {
  resource-group = {
    labels = ["name"]
    format = "%v-rg"
  }
  container-group = {
    labels = ["namespace", "environment", "stage", "name"]
    format = "%v-%v-%v-%v-aci"
  }
}

tags = {
  Terraform = "True"
}
