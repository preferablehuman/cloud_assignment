variable "region" { type = string; default = "us-east-1" }
variable "project_name" { type = string }
variable "ssh_public_key"{ type = string }
variable "instance_type" { type = string; default = "t3.micro" }
variable "s3_bucket_name"{ type = string }
variable "master_instance_count" { type = number; default = 1 }
variable "worker_instance_count" { type = number; default = 2 }
variable "root_volume_size" { type = number; default = 10 } # GB