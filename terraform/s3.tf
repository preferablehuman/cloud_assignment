resource "aws_s3_bucket" "data_bucket" {
bucket = var.s3_bucket_name
tags = { Name = var.project_name }
}


resource "aws_s3_bucket_versioning" "v" {
bucket = aws_s3_bucket.data_bucket.id
versioning_configuration { status = "Disabled" }
}


resource "aws_s3_bucket_public_access_block" "pab" {
bucket = aws_s3_bucket.data_bucket.id
block_public_acls = true
block_public_policy = true
ignore_public_acls = true
restrict_public_buckets = true
}