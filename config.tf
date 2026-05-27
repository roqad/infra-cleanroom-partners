# ═══════════════════════════════════════════════════════════════════════════════
# This is the only file you need to edit.
#
# 1. Set schema_type — see README.md for the column requirements of each schema.
# 2. Set configured_table_name to a value unique to this provider if multiple
#    providers join the same collaboration with the same schema_type.
# 3. Fill in your Glue table name and S3 location.
# ═══════════════════════════════════════════════════════════════════════════════

locals {
  # "hem_source_file" — columns: first_party_id_type, first_party_id_value, matched_id_type, matched_id_value
  # "token_hem"       — same columns plus d (date partition)
  schema_type = "hem_source_file"

  # SQL name registered in the Clean Rooms collaboration.
  # Must be unique per member within the collaboration — change this if another
  # provider already uses the same schema_type in the same collaboration.
  configured_table_name = local.schema_type

  # Your Glue table
  glue_database = "your_database"
  glue_table    = "your_table"

  # Your S3 location
  s3_bucket     = "your-bucket"
  s3_key_prefix = "path/to/your/table/"
}
