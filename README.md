# Secrets Manager Terraform
### Created by Ronaldo Nazo :D
This Repo is used to create Secrets Manager on AWS using Terraform scripting!

This is a script on terraform used for :
Creates a Secrets Manager for a specific RDS database by providing RDS id 
Provide username and password of RDS that is going to be created.
This script is dynamic ,so it will suit with every kind of RDS

It creates Security groups for VPC endpoint for SM .

## USAGE
```hcl
module "Secret_Manager" {
  source                = "github.com/RonaldoNazo/terraform-aws-secretsmanager"
  RDS_Username          = var.RDS_Username
  RDS_Password          = var.RDS_Password
  RDS_instance_id       = var.RDS_instance_id
  RDS_Subne_1_id        = var.RDS_Subne_1_id
  RDS_Subne_2_id        = var.RDS_Subne_2_id
  kms_key_by_arn        = null #var.kms_key_by_arn #if null ,default kms will be created
  RDS_SECURITY_GROUP_ID = var.RDS_SECURITY_GROUP_ID
  region                = var.region #default us-east-1
  engine                = var.engine
  name_prefix           = local.name
}
```
