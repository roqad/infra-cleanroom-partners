# Roqad-provided constants - do not change.

locals {
  region = "eu-west-1"

  # Roqad collaboration ID - provided during onboarding.
  collaboration_id = "00000000-0000-0000-0000-000000000000"
}

data "aws_caller_identity" "current" {}

# Accepting the Roqad collaboration invitation.
resource "awscc_cleanrooms_membership" "this" {
  collaboration_identifier = local.collaboration_id
  query_log_status         = "ENABLED"
}

# One resource per entry in local.tables (config.tf).
# allowed_columns and analysis_rules are set per-table in config.tf.
resource "awscc_cleanrooms_configured_table" "this" {
  for_each        = local.tables
  name            = each.key
  description     = "Provider data for Roqad cleanroom collaboration."
  allowed_columns = each.value.allowed_columns
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
      database_name = each.value.glue_database
      table_name    = each.value.glue_table
      region        = local.region
    }
  }
}

resource "awscc_cleanrooms_configured_table_association" "this" {
  for_each                    = local.tables
  name                        = each.key
  configured_table_identifier = awscc_cleanrooms_configured_table.this[each.key].configured_table_identifier
  membership_identifier       = awscc_cleanrooms_membership.this.membership_identifier
  role_arn                    = aws_iam_role.cleanrooms.arn
}
