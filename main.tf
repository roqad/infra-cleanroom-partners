# ── Roqad-provided constants — do not change ─────────────────────────────────
# These are set once when your account is onboarded.
# Roqad will notify you if any value changes (e.g. a new analysis template version)
# and ask you to re-apply.

locals {
  region = "eu-west-1"

  # Replace with the value from Roqad (format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
  collaboration_id = "00000000-0000-0000-0000-000000000000"

  # All current Roqad analysis template ARNs. Both old and new versions are listed
  # during template upgrades so queries keep running across the rollover.
  # Replace with the ARN(s) from Roqad.
  analysis_template_arns = [
    "arn:aws:cleanrooms:eu-west-1:000000000000:membership/00000000-0000-0000-0000-000000000000/analysistemplate/00000000-0000-0000-0000-000000000000",
  ]
}

# ── Computed ──────────────────────────────────────────────────────────────────

data "aws_caller_identity" "current" {}

locals {
  hem_source_file_bucket_arn = "arn:aws:s3:::${local.hem_source_file_s3_bucket}"
  hem_source_file_prefix_arn = "arn:aws:s3:::${local.hem_source_file_s3_bucket}/${local.hem_source_file_s3_key_prefix}*"
  token_hem_bucket_arn       = "arn:aws:s3:::${local.token_hem_s3_bucket}"
  token_hem_prefix_arn       = "arn:aws:s3:::${local.token_hem_s3_bucket}/${local.token_hem_s3_key_prefix}*"
}

# ── Membership ────────────────────────────────────────────────────────────────
# Creating this resource accepts the Roqad collaboration invitation.
# This account is a data provider — Roqad runs all queries on behalf of customers.

resource "awscc_cleanrooms_membership" "this" {
  collaboration_identifier = local.collaboration_id
  query_log_status         = "ENABLED"
}

# ── Configured tables ─────────────────────────────────────────────────────────
# allowed_columns and analysis_rules are fixed by the Roqad analysis template.
# Do not change these.

resource "awscc_cleanrooms_configured_table" "hem_source_file" {
  name        = "hem_source_file"
  description = "Token-to-HEM provider mappings for Roqad match-stats collaboration."

  allowed_columns = [
    "first_party_id_type",
    "first_party_id_value",
    "matched_id_type",
    "matched_id_value",
  ]

  analysis_method = "DIRECT_QUERY"

  analysis_rules = [
    {
      type = "CUSTOM"
      policy = {
        v1 = {
          custom = {
            allowed_analyses    = local.analysis_template_arns
            additional_analyses = "NOT_ALLOWED"
          }
        }
      }
    }
  ]

  table_reference = {
    glue = {
      database_name = local.hem_source_file_glue_database
      table_name    = local.hem_source_file_glue_table
      region        = local.region
    }
  }
}

resource "awscc_cleanrooms_configured_table" "token_hem" {
  name        = "token_hem"
  description = "Dated token-to-HEM snapshot for Roqad match-stats collaboration. Query uses only the most recent date partition."

  allowed_columns = [
    "first_party_id_type",
    "first_party_id_value",
    "matched_id_type",
    "matched_id_value",
    "d",
  ]

  analysis_method = "DIRECT_QUERY"

  analysis_rules = [
    {
      type = "CUSTOM"
      policy = {
        v1 = {
          custom = {
            allowed_analyses    = local.analysis_template_arns
            additional_analyses = "NOT_ALLOWED"
          }
        }
      }
    }
  ]

  table_reference = {
    glue = {
      database_name = local.token_hem_glue_database
      table_name    = local.token_hem_glue_table
      region        = local.region
    }
  }
}

# ── Configured table associations ─────────────────────────────────────────────
# SQL names (hem_source_file, token_hem) are fixed — referenced by the analysis template.

resource "awscc_cleanrooms_configured_table_association" "hem_source_file" {
  name                        = "hem_source_file"
  description                 = "Token-to-HEM provider mappings (SQL name: hem_source_file)."
  configured_table_identifier = awscc_cleanrooms_configured_table.hem_source_file.configured_table_identifier
  membership_identifier       = awscc_cleanrooms_membership.this.membership_identifier
  role_arn                    = aws_iam_role.cleanrooms.arn
}

resource "awscc_cleanrooms_configured_table_association" "token_hem" {
  name                        = "token_hem"
  description                 = "Dated token-to-HEM snapshot (SQL name: token_hem)."
  configured_table_identifier = awscc_cleanrooms_configured_table.token_hem.configured_table_identifier
  membership_identifier       = awscc_cleanrooms_membership.this.membership_identifier
  role_arn                    = aws_iam_role.cleanrooms.arn
}
