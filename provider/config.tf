# ═══════════════════════════════════════════════════════════════════════════════
# This is the only file you need to edit.
#
# Fill in your Glue table and S3 location below.
# The table must have these columns:
#   first_party_id_type, first_party_id_value, matched_id_type, matched_id_value
# ═══════════════════════════════════════════════════════════════════════════════

locals {
  tables = {
    hem_source_file = {
      glue_database = "your_database"
      glue_table    = "your_table"
      s3_bucket     = "your-bucket"
      s3_key_prefix = "path/to/your/table/"
    }
  }
}
