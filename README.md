# infra-customer-cleanroom

Terraform modules for customers joining the Roqad Multi-Customer Cleanroom.

## Structure

### `provider/`
For **data providers** (e.g. EchoAnalytics, SSMAS) that join the cleanroom as AWS Clean Rooms members and contribute data. Applies to accounts that have their own HEM-MAID data to share.

### `customer/`
For **customers** who upload their HEM batches to Roqad's S3 bucket for match-rate testing or delivery. These customers do not join the cleanroom as AWS members — Roqad operates the cleanroom on their behalf.

## Provider setup (`provider/`)

See `provider/config.tf` for required variables. The provider joins the AWS Clean Rooms collaboration as a member and exposes their Glue table.

Membership is added manually by Roqad: AWS console → Clean Rooms → collaboration → Members.

## Customer setup (`customer/`)

Provisions IAM credentials scoped to the customer's S3 prefix.

1. Edit `customer/config.tf`: set `customer_id` and `customer_name`
2. `terraform init && terraform apply`
3. Share `access_key_id` and `secret_access_key` outputs with the customer securely
4. Customer uploads HEM parquet files to the `s3_upload_path` output
5. Roqad adds the customer to the k8s pipeline config and runs the cleanroom

The customer's `customer_id` must match what's configured in Roqad's internal pipeline.
