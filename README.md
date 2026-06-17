# infra-customer-cleanroom

Terraform modules for onboarding data providers and customers to the Roqad Multi-Customer Cleanroom.

## Structure

### `provider/`

For **data providers** that join the cleanroom as AWS Clean Rooms members and contribute their data table. Applies to accounts that have their own HEM-MAID data to share.

### `customer/`

For **customers** who upload their HEM batches to Roqad's S3 bucket for match-rate testing or delivery. Customers do not join the cleanroom as AWS members - Roqad operates the cleanroom on their behalf.

## Provider setup (`provider/`)

See `provider/config.tf` for required variables. The provider joins the AWS Clean Rooms collaboration as a member and registers their Glue table.

Membership invitation is sent by Roqad. Once invited, the provider:

1. Clones this repo
2. Fills in `provider/config.tf` with their Glue table and S3 location
3. Fills in `provider/main.tf` with the collaboration ID and analysis template ARNs provided by Roqad
4. Runs `terraform init && terraform apply`
5. Confirms setup is complete by sharing the `membership_id` output with Roqad

## Customer setup (`customer/`)

Provisions IAM credentials scoped to the customer's S3 prefix.

1. Edit `customer/config.tf`: set `customer_id` and `customer_name`
2. Run `terraform init && terraform apply`
3. Share `access_key_id` and `secret_access_key` outputs with the customer via a secure channel
4. Customer uploads HEM CSV files to the `s3_upload_path` output
5. Roqad adds the customer to the pipeline config and runs the cleanroom

The `customer_id` must match what Roqad configures in the internal pipeline.
