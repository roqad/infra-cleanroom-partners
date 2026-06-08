output "iam_user_name" {
  value       = aws_iam_user.upload.name
  description = "IAM user name for the customer upload credentials."
}

output "access_key_id" {
  value       = aws_iam_access_key.upload.id
  description = "AWS access key ID — share with the customer."
}

output "secret_access_key" {
  value       = aws_iam_access_key.upload.secret
  sensitive   = true
  description = "AWS secret access key — share with the customer via a secure channel."
}

output "s3_upload_path" {
  value       = "s3://${local.s3_bucket}/${local.s3_prefix}"
  description = "S3 path the customer should upload their HEM parquet files to."
}
