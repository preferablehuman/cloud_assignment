resource "aws_iam_role" "ec2_role" {
name = "${var.project_name}-ec2-role"
assume_role_policy = jsonencode({
Version = "2012-10-17",
Statement = [{
Action = "sts:AssumeRole",
Effect = "Allow",
Principal = { Service = "ec2.amazonaws.com" }
}]
})
}


# Restrict to just the project bucket in production; for assignment simplicity, allow S3 read/write
resource "aws_iam_role_policy" "s3_access" {
name = "${var.project_name}-s3-policy"
role = aws_iam_role.ec2_role.id
policy = jsonencode({
Version = "2012-10-17",
Statement = [{
Effect = "Allow",
Action = ["s3:*"],
Resource = ["*"]
}]
})
}


resource "aws_iam_instance_profile" "ec2_profile" {
name = "${var.project_name}-ec2-profile"
role = aws_iam_role.ec2_role.name
}


resource "aws_key_pair" "this" {
key_name = "${var.project_name}-key"
public_key = var.ssh_public_key
}