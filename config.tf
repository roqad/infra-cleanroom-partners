# ═══════════════════════════════════════════════════════════════════════════════
# This is the only file you need to edit.
#
# Fill in your Glue table names and S3 locations below.
# See README.md for the required column schemas for each table.
# ═══════════════════════════════════════════════════════════════════════════════

locals {
  # Table with all token-to-HEM mappings.
  # Required columns: first_party_id_type, first_party_id_value, matched_id_type, matched_id_value
  hem_source_file_glue_database = "your_database"
  hem_source_file_glue_table    = "hem_source_file"
  hem_source_file_s3_bucket     = "your-bucket"
  hem_source_file_s3_key_prefix = "path/to/hem_source_file/"

  # Dated snapshot table — query reads only the most recent partition (MAX(d)).
  # Required columns: first_party_id_type, first_party_id_value, matched_id_type, matched_id_value, d (date)
  token_hem_glue_database = "your_database"
  token_hem_glue_table    = "token_hem"
  token_hem_s3_bucket     = "your-bucket"
  token_hem_s3_key_prefix = "path/to/token_hem/"
}
