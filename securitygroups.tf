###Data to fetch sec group vpc_id
data "aws_security_group" "RDS_sec" {
  id = var.RDS_SECURITY_GROUP_ID
}

###RDS SG RULE TO ALLOW TRAFFIC FROM LAMBDA ROTATOR ###
resource "aws_security_group_rule" "Rds_lambda" {
  description = "RDS SG RULE TO ALLOW TRAFFIC FROM LAMBDA ROTATOR"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id   = aws_security_group.Lambda_rotator.id
  security_group_id = var.RDS_SECURITY_GROUP_ID
}
##################
##################

###LAMBDA SECURITY GROUP  ALLOW ACCESS TO SECRETS MANAGER ENDPOINT AND FROM RDS ###
resource "aws_security_group" "Lambda_rotator" {
  name        = "Lambda-Rotator-SG"
  description = "Allow trafic to SM VPC endpoint and RDS "
  vpc_id      = data.aws_security_group.RDS_sec.vpc_id

  ingress {
    description     = "All Traffic from SM-Endpoint"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.secrets_manager_endpoint.id}"]
  }
  egress {
    description     = "All Traffic to SM-Endpoint and RDS SG"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.secrets_manager_endpoint.id}", "${var.RDS_SECURITY_GROUP_ID}"]
  }
  tags = merge(var.common_tags, {
  name        = "Lambda-Rotator-SG"
  })
}
###SECRETS MANAGER ENDPOINT SECURITY GROUP ###
resource "aws_security_group" "secrets_manager_endpoint" {
  name        = "SM-Endpoint-SG"
  description = "Allow trafic from lambda to endpoint"
  vpc_id      = data.aws_security_group.RDS_sec.vpc_id
  tags = merge(var.common_tags, {
  name        = "SM-Endpoint-SG"
  })
}
###SM ENDPOINT RULE TO ALLOW HTTPS FROM LAMBDA###
resource "aws_security_group_rule" "SM_Lambda_ingress" {
  depends_on = [aws_security_group.Lambda_rotator,
    aws_security_group.secrets_manager_endpoint   
  ]
  type              = "ingress"
  description       = "Https from lambda"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.Lambda_rotator.id
  security_group_id = aws_security_group.secrets_manager_endpoint.id
}
###SM ENDPOINT RULE TO ALLOW HTTPS TO LAMBDA###
resource "aws_security_group_rule" "SM_Lambda_egress" {
  depends_on = [aws_security_group.Lambda_rotator,
    aws_security_group.secrets_manager_endpoint    
  ]
  type              = "egress"
  description       = "Https to lambda"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id   = aws_security_group.Lambda_rotator.id
  security_group_id = aws_security_group.secrets_manager_endpoint.id
}