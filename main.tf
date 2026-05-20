data "aws_caller_identity" "current" {}

locals {
  hem_source_file_bucket_arn = "arn:aws:s3:::${var.hem_source_file_s3_bucket}"
  hem_source_file_prefix_arn = "arn:aws:s3:::${var.hem_source_file_s3_bucket}/${var.hem_source_file_s3_key_prefix}*"
  token_hem_bucket_arn       = "arn:aws:s3:::${var.token_hem_s3_bucket}"
  token_hem_prefix_arn       = "arn:aws:s3:::${var.token_hem_s3_bucket}/${var.token_hem_s3_key_prefix}*"
}

# ── Membership ────────────────────────────────────────────────────────────────
# Creating this resource accepts the Roqad collaboration invitation.
# This account is a data provider only — Roqad runs all queries on behalf of customers.

resource "awscc_cleanrooms_membership" "this" {
  collaboration_identifier = var.collaboration_id
  query_log_status         = "ENABLED"
}

# ── Configured tables ─────────────────────────────────────────────────────────
# allowed_columns and analysis_rules are fixed — they are dictated by the Roqad
# analysis template and must not be changed.

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
            allowed_analyses    = [var.analysis_template_arn]
            additional_analyses = "NOT_ALLOWED"
          }
        }
      }
    }
  ]

  table_reference = {
    glue = {
      database_name = var.hem_source_file_glue_database
      table_name    = var.hem_source_file_glue_table
      region        = var.region
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
            allowed_analyses    = [var.analysis_template_arn]
            additional_analyses = "NOT_ALLOWED"
          }
        }
      }
    }
  ]

  table_reference = {
    glue = {
      database_name = var.token_hem_glue_database
      table_name    = var.token_hem_glue_table
      region        = var.region
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
