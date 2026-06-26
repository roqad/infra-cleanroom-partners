# infra-customer-cleanroom

Terraform modules for onboarding data providers and customers to the Roqad Multi-Customer Cleanroom.

## Structure

### `provider/`

For **data providers** that join the cleanroom as AWS Clean Rooms members and contribute their data table. Applies to accounts that have their own HEM-MAID data to share.

### `customer/`

For **customers** who upload their HEM batches to Roqad's S3 bucket for match-rate testing or delivery. Customers do not join the cleanroom as AWS members - Roqad operates the cleanroom on their behalf.

## Provider setup (`provider/`)

The provider joins the AWS Clean Rooms collaboration as a member and registers one or more Glue tables. `provider/config.tf` is the only file that needs to be edited.

Roqad provides:
- Collaboration ID (set in `provider/main.tf`)
- Table names, `allowed_columns`, and analysis template ARNs (set in `provider/config.tf`)

Steps:

1. Clone this repo
2. Fill in `provider/config.tf`: `iam_role_name`, `analysis_template_arns`, and one entry per table in `tables`
3. Run `tofu init && tofu apply`
4. Share the `membership_id` output with Roqad to confirm setup

## Customer setup (`customer/`)

Provisions IAM credentials scoped to the customer's S3 prefix.

1. Edit `customer/config.tf`: set `customer_id` and `customer_name`
2. Run `terraform init && terraform apply`
3. Share `access_key_id` and `secret_access_key` outputs with the customer via a secure channel
4. Customer uploads HEM CSV files to the `s3_upload_path` output
5. Roqad adds the customer to the pipeline config and runs the cleanroom

The `customer_id` must match what Roqad configures in the internal pipeline.
