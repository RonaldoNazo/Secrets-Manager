###### VPC Endpoint ######
resource "aws_vpc_endpoint" "Secret_manager" {
  vpc_id              = data.aws_security_group.RDS_sec.vpc_id
  service_name        = "com.amazonaws.${var.region}.secretsmanager"
  subnet_ids          = [var.RDS_Subne_1_id, var.RDS_Subne_2_id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.secrets_manager_endpoint.id]
  private_dns_enabled = true
}

####Local Value for SecretString#### The only way!!!
locals {
   SecretStringTemplate = {
      username = var.RDS_Username
      password = var.RDS_Password
   }
   SecretString = jsonencode(local.SecretStringTemplate)
   RotationType = jsondecode(file("${path.module}/RotationType.json"))[var.engine]
}


data "template_file" "Lambda_rotator_properties"{
 template = file("${path.module}/CloudFormation-LambdaRotator.json")
 vars = {
   RotationLambdaName = "${var.name_prefix}LambdaRotator"
   RDS_Subne_1_id = var.RDS_Subne_1_id
   RDS_Subne_2_id = var.RDS_Subne_2_id
   LambdaSecGroup = aws_security_group.Lambda_rotator.id
   RotationType = local.RotationType
   MyDBInstance = var.RDS_instance_id
 }
}

resource "local_file" "cf_script" {
    content = "${data.template_file.Lambda_rotator_properties.rendered}"
    filename = "./CF-script.json"
}
resource "aws_s3_bucket" "CF_script" {
  bucket_prefix = "${var.name_prefix}temp"
  tags = {
    Created-from        = "Terraform"
    State = "Temporary"
    Role = "Holds_CF_Script"
  }
}

resource "aws_s3_object" "example" {
  depends_on = [
    local_file.cf_script
  ]
  key                    = "CF-script.json"
  bucket                 = aws_s3_bucket.CF_script.id
  source                 = "CF-script.json"
}
resource "aws_cloudformation_stack" "secret_manager_rotator" {
  depends_on = [
    aws_s3_object.example
  ]
  name = "${var.name_prefix}secret-manager"
  parameters = {
    SecretString = "${local.SecretString}"
  }
  iam_role_arn = try(var.cloudformation_role_arn,null)
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  template_url = "https://${aws_s3_bucket.CF_script.id}.s3.amazonaws.com/CF-script.json"
}

