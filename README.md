
POC to explore how to create Azure VM using Terraform (and Nixos OS)
<br>
<br>

Azure Subscription and all usage rights are needed

Start nix-shell with Azure CLI:
(with Azure and Terraform)

 *nix-shell*

Log to Azure:

*az login*

<br>
<br>
------------------------

*terraform init*

*terraform plan*

*terraform apply*

*terraform destroy*

<br>
<br>
  DO NOT STORE terraform.tfvars file to public git!
  It includes Azure credentials (use Azure CLi, UI console to find them .TODO ADD PATH)


Reading material:

[1] [Terraform Azure Provider Guide](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

[2] [Terraform Azure Dependencies](https://developer.hashicorp.com/terraform/tutorials/configuration-language/dependencies)


