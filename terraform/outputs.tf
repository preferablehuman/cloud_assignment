output "spark_master_public_ip" {
value = aws_instance.master[0].public_ip
}


output "spark_master_private_ip" {
value = aws_instance.master[0].private_ip
}


output "spark_master_url" {
value = "spark://${aws_instance.master[0].private_ip}:7077"
}


output "s3_bucket_name" {
value = aws_s3_bucket.data_bucket.bucket
}