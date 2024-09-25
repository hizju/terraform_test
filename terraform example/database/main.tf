
variable "private_subnet" {
  description = "The private subnets for the database"
  type        = list(string)
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "mydb-subnet-group"
  subnet_ids = var.private_subnet

  tags = {
    Name = "DB Subnet Group"
  }
}

resource "aws_db_instance" "db" {
  identifier        = "mydb"
  engine            = "mysql"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  db_name           = "mydb"
  username          = "admin"
  password          = "password123"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "MyDBInstance"
  }
}

output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}
