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

  columns_by_schema = {
    hem_source_file = ["first_party_id_type", "first_party_id_value", "matched_id_type", "matched_id_value"]
    token_hem       = ["first_party_id_type", "first_party_id_value", "matched_id_type", "matched_id_value", "d"]
  }
}

data "aws_caller_identity" "current" {}

# ── Membership ────────────────────────────────────────────────────────────────
# Creating this resource accepts the Roqad collaboration invitation.
# This account is a data provider — Roqad runs all queries on behalf of customers.

resource "awscc_cleanrooms_membership" "this" {
  collaboration_identifier = local.collaboration_id
  query_log_status         = "ENABLED"
}

# ── Configured tables ─────────────────────────────────────────────────────────
# One resource per entry in local.tables (config.tf).
# allowed_columns and analysis_rules are fixed by the Roqad analysis template.
# Do not change these.

resource "awscc_cleanrooms_configured_table" "this" {
  for_each        = local.tables
  name            = each.key
  description     = "Provider data for Roqad match-stats collaboration."
  allowed_columns = local.columns_by_schema[each.key]
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
