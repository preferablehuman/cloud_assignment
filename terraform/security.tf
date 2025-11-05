resource "aws_security_group" "spark_sg" {
name = "${var.project_name}-sg"
description = "Allow SSH and Spark UI/ports"
vpc_id = aws_vpc.main.id


ingress { description = "SSH" from_port = 22 to_port = 22 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
ingress { description = "Spark master UI" from_port = 8080 to_port = 8080 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
ingress { description = "Spark worker UI" from_port = 8081 to_port = 8081 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
ingress { description = "Spark master RPC" from_port = 7077 to_port = 7077 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }
ingress { description = "Spark app UI" from_port = 4040 to_port = 4050 protocol = "tcp" cidr_blocks = ["0.0.0.0/0"] }


egress { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }


tags = { Name = "${var.project_name}-sg" }
}