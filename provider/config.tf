# ============================================================
# This is the only file you need to edit.
# Roqad will provide the exact values to fill in below.
# ============================================================

locals {
  # IAM role name created in your account for Clean Rooms access.
  iam_role_name = "roqad-cleanrooms-provider"

  # Analysis template ARNs for this collaboration.
  # Fetch the current list from your membership:
  #   aws cleanrooms list-analysis-templates --membership-identifier <your_membership_id>
  # Re-apply whenever new templates are deployed.
  analysis_template_arns = [
    # "arn:aws:cleanrooms:eu-west-1:...",
  ]

  # Tables you are contributing to the collaboration.
  # Roqad will tell you:
  #   - which table names (keys) to use
  #   - which allowed_columns each table requires
  # Add one entry per table. The key is the SQL name used in Roqad queries.
  tables = {
    # example = {
    #   glue_database   = "your_database"
    #   glue_table      = "your_table"
    #   s3_bucket       = "your-bucket"
    #   s3_key_prefix   = "path/to/table/"   # must end with /
    #   allowed_columns = ["col1", "col2"]   # provided by Roqad
    # }
  }
}
