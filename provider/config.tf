# ═══════════════════════════════════════════════════════════════════════════════
# This is the only file you need to edit.
#
# Add one entry per table you contribute to the collaboration.
# Keys must be the exact SQL name the analysis template uses:
#   "hem_source_file" — columns: first_party_id_type, first_party_id_value,
#                                matched_id_type, matched_id_value
#   "token_hem"       — same columns plus d (date partition)
#
# Both tables are required by the match-stats templates; include whichever you have.
# ═══════════════════════════════════════════════════════════════════════════════

locals {
  tables = {
    hem_source_file = {
      glue_database = "your_database"
      glue_table    = "your_hem_source_file_table"
      s3_bucket     = "your-bucket"
      s3_key_prefix = "path/to/hem_source_file/"
    }
    # Uncomment and fill if you also have token_hem data:
    # token_hem = {
    #   glue_database = "your_database"
    #   glue_table    = "your_token_hem_table"
    #   s3_bucket     = "your-bucket"
    #   s3_key_prefix = "path/to/token_hem/"
    # }
  }
}
