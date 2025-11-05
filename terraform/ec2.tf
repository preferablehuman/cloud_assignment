data "aws_ami" "ubuntu" {
most_recent = true
owners = ["099720109477"] # Canonical
filter { name = "name" values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] }
}


locals {
master_count = var.master_instance_count
worker_count = var.worker_instance_count
}


resource "aws_instance" "master" {
count = local.master_count
ami = data.aws_ami.ubuntu.id
instance_type = var.instance_type
subnet_id = aws_subnet.public_a.id
vpc_security_group_ids = [aws_security_group.spark_sg.id]
associate_public_ip_address = true
iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
key_name = aws_key_pair.this.key_name
root_block_device { volume_size = var.root_volume_size }


user_data = templatefile("${path.module}/user_data_master.sh", {
s3_bucket = aws_s3_bucket.data_bucket.bucket,
region = var.region
})


tags = { Name = "${var.project_name}-master" }
}


resource "aws_instance" "worker" {
count = local.worker_count
ami = data.aws_ami.ubuntu.id
instance_type = var.instance_type
subnet_id = count.index % 2 == 0 ? aws_subnet.public_a.id : aws_subnet.public_b.id
vpc_security_group_ids = [aws_security_group.spark_sg.id]
associate_public_ip_address = true
iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
key_name = aws_key_pair.this.key_name
root_block_device { volume_size = var.root_volume_size }


user_data = templatefile("${path.module}/user_data_worker.sh", {
master_private_ip = aws_instance.master[0].private_ip,
region = var.region
})


tags = { Name = "${var.project_name}-worker-${count.index}" }
}