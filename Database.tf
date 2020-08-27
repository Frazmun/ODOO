##########################################
##  STA-PRODUCT-1 ODOO App
##  Customer RDS Instance 
##########################################
#  This will setup the Postgres DB for a single
#  installation of OODO in the customers 
#  private VPC.
###########################################

resource "aws_db_instance" "CustomerDB" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = var.dbversion
  instance_class       = var.rds_instance_type
  availability_zone    = "eu-west-2a"
  name                 = "postgres"
  username             = var.dbuser
  password             = var.dbpassword
  db_subnet_group_name = aws_db_subnet_group.main_db_subnet_group.name

  publicly_accessible     = "false"
  vpc_security_group_ids  = [aws_security_group.odooDBSG.id]
  backup_retention_period = "0"
  skip_final_snapshot     = true
  identifier              = "customer-odoo"
  tags = {
    "Name" = var.environment_name
  } 
}

output "db_address" {
  value = aws_db_instance.CustomerDB.address
}

output "db_user" {
  value = var.dbuser
}

output "db_password" {
  value = var.dbpassword
}

