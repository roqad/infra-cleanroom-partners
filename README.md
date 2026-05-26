# Roqad Match-Stats Cleanroom — Data Provider Setup

This repository sets up your AWS account as a data provider in a Roqad match-stats
collaboration. You contribute token→HEM mapping tables; Roqad runs overlap queries
on behalf of its customers and reports aggregate match statistics back to them.
Your token data never leaves your account.

> **This repo is for data providers** (companies with token→HEM data, e.g. Zetaglobal, PayPal).
> End customers requesting match stats have no AWS involvement — they send a file to Roqad.

## Prerequisites

Before running Terraform:

1. **Contact Roqad** with your AWS account ID. Roqad must add your account to the
   collaboration and will reply with a `collaboration_id` and `analysis_template_arns`.
   Fill both values into `main.tf` (marked with comments).

2. **Your Glue tables must exist** with the schemas below. This module references
   them — it does not create them.

3. **OpenTofu ≥ 1.5** (or Terraform ≥ 1.5) and AWS credentials with permissions
   to create IAM roles and Clean Rooms resources in `eu-west-1`.

## Setup

1. Edit `config.tf` — fill in your Glue table names and S3 locations.
2. Edit `main.tf` — replace the placeholder `collaboration_id` and `analysis_template_arns` with the values from Roqad.

```sh
tofu init
tofu apply
```

After apply, share the `membership_id` output with Roqad to confirm your setup is complete.

## Required Glue table schemas

### hem_source_file — all token-to-HEM mappings

| Column | Type |
|---|---|
| `first_party_id_type` | string |
| `first_party_id_value` | string |
| `matched_id_type` | string |
| `matched_id_value` | string |

### token_hem — dated snapshot, filtered to most recent partition by `d`

| Column | Type |
|---|---|
| `first_party_id_type` | string |
| `first_party_id_value` | string |
| `matched_id_type` | string |
| `matched_id_value` | string |
| `d` | string (date as `YYYY-MM-DD`, used as partition key) |

Additional columns are allowed and are not exposed to the collaboration.

## What this creates

| Resource | Purpose |
|---|---|
| `awscc_cleanrooms_membership` | Joins the Roqad collaboration (creating this = accepting the invite) |
| `awscc_cleanrooms_configured_table` × 2 | Registers `hem_source_file` and `token_hem` with a CUSTOM analysis rule |
| `awscc_cleanrooms_configured_table_association` × 2 | Makes the tables queryable within the collaboration |
| `aws_iam_role` + inline policy | Allows the Clean Rooms service to read your Glue metadata and S3 data — scoped to the two prefixes you configure, nothing else |

## Security

The CUSTOM analysis rule on both configured tables restricts queries to a fixed set of
Roqad analysis templates. Those templates produce only aggregate values per country:

- `country`
- `input_distinct_hem_count`
- `matched_distinct_hem_count`
- `match_rate`

No row-level data from your tables is accessible through this collaboration.
