# Customer onboarding for the Roqad Multi-Customer Cleanroom.
#
# This Terraform module provisions IAM credentials for a customer to upload
# their HEM (Hashed Email) batches to Roqad's S3 bucket.
#
# Usage:
#   1. Fill in customer_id and customer_name in config.tf.
#   2. Run: terraform init && terraform apply
#   3. Share access_key_id and secret_access_key (output) with the customer securely.
#   4. Tell the customer to upload parquet files to the s3_upload_path output.
#
# Note: Cleanroom membership is managed separately by Roqad (AWS console).
