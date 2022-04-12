variable "RDS_Username" {
  type = string
  description = "Enter the RDS Database Username"
  default = "Username"
}
variable "RDS_Password" {
  type = string
  description = "Enter the RDS Database Password"
  default = "Password"
}
variable "RDS_instance_id" {
  type = string
  description = "Enter the RDS instance Id"
}
variable "RDS_Subne_1_id" {
  type = string
  description = "Enter the RDS subnet 1"
}
variable "RDS_Subne_2_id" {
  type = string
  description = "Enter the RDS subnet 2"
}
variable "kms_key_by_arn" {
  type = string
  description = "Enter the kms arn to encrypt the SM and Lambda"
  default = null
}
variable "RDS_SECURITY_GROUP_ID" {
  type = string
  description = "Enter the RDS SEC GROUP ID TO CREATE RULES FOR TRAFFIC"
}
variable "engine" {
  type = string
  description = "Enter the engine  of your RDS"
}
variable "name_prefix" {
  description = "Naming prefix for resources to create"
  default = ""
}
variable "region" {
  type = string
  default = "us-east-1"  
}
variable "common_tags" {
  description = "Tags"
  default = {
    Created_from = "Terraform"
  }
}