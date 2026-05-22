# ── Provided by Roqad — set these in terraform.tfvars ─────────────────────────
# Roqad sends both values when your AWS account is added to the collaboration.

variable "collaboration_id" {
  description = "Clean Rooms collaboration ID. Provided by Roqad — set in terraform.tfvars."
  type        = string
}

variable "analysis_template_arns" {
  description = "ARNs of all Roqad analysis templates. Provided by Roqad — set in terraform.tfvars. All must be whitelisted so queries can run after template updates."
  type        = list(string)
}

variable "region" {
  description = "AWS region. Must be eu-west-1 — that is where the Roqad collaboration lives."
  type        = string
  default     = "eu-west-1"
}

# ── Fill in these 8 values ────────────────────────────────────────────────────

variable "hem_source_file_glue_database" {
  description = "Glue catalog database containing your hem_source_file table."
  type        = string
}

variable "hem_source_file_glue_table" {
  description = <<-EOT
    Glue table for token-to-HEM mappings (no date filter — all rows are used).
    Required columns: first_party_id_type (string), first_party_id_value (string),
                      matched_id_type (string), matched_id_value (string).
  EOT
  type        = string
}

variable "hem_source_file_s3_bucket" {
  description = "S3 bucket name where hem_source_file data is stored."
  type        = string
}

variable "hem_source_file_s3_key_prefix" {
  description = "S3 key prefix for hem_source_file data. Include trailing slash, e.g. hems/ or data/hem/year=2025/."
  type        = string
}

variable "token_hem_glue_database" {
  description = "Glue catalog database containing your token_hem table. May be the same as hem_source_file_glue_database."
  type        = string
}

variable "token_hem_glue_table" {
  description = <<-EOT
    Glue table for the dated token-to-HEM snapshot. The query uses only the most recent partition (MAX(d)).
    Required columns: first_party_id_type (string), first_party_id_value (string),
                      matched_id_type (string), matched_id_value (string), d (date).
  EOT
  type        = string
}

variable "token_hem_s3_bucket" {
  description = "S3 bucket name where token_hem data is stored. May be the same as hem_source_file_s3_bucket."
  type        = string
}

variable "token_hem_s3_key_prefix" {
  description = "S3 key prefix for token_hem data. Include trailing slash, e.g. tokens/ or data/token_hem/."
  type        = string
}
