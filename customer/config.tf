locals {
  region = "eu-west-1"

  # Customer identifier (short form, must match the ID used in Roqad's pipeline config).
  customer_id = "REPLACE_WITH_CUSTOMER_ID"

  # Human-readable name (used in IAM resource names).
  customer_name = "REPLACE_WITH_CUSTOMER_NAME"

  # Roqad's S3 bucket where customer HEMs are uploaded.
  # Do not change - provided by Roqad.
  s3_bucket = "roqad-cleanroom-hemmatch-out-eu-west-1"

  # S3 prefix scoped to this customer. Customer can only write here.
  s3_prefix = "customer-hems-input/customer_id=${local.customer_id}/"
}
