# IAM role assumed by the Clean Rooms service to read your Glue catalog and S3 data.
# Scoped to the two tables and S3 prefixes you configure — nothing else.

data "aws_iam_policy_document" "cleanrooms_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cleanrooms.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "cleanrooms" {
  name                 = "match-stats-cleanrooms-member"
  assume_role_policy   = data.aws_iam_policy_document.cleanrooms_assume.json
  max_session_duration = 3600
}

data "aws_iam_policy_document" "cleanrooms_access" {
  statement {
    sid    = "S3ReadHemSourceFile"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = [local.hem_source_file_prefix_arn]
  }

  statement {
    sid    = "S3ReadTokenHem"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = [local.token_hem_prefix_arn]
  }

  statement {
    sid     = "S3ListBuckets"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = distinct([
      local.hem_source_file_bucket_arn,
      local.token_hem_bucket_arn,
    ])
  }

  statement {
    sid    = "GlueReadTables"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
    ]
    resources = distinct([
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/${var.hem_source_file_glue_database}",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.hem_source_file_glue_database}/${var.hem_source_file_glue_table}",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/${var.token_hem_glue_database}",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.token_hem_glue_database}/${var.token_hem_glue_table}",
    ])
  }
}

resource "aws_iam_role_policy" "cleanrooms_access" {
  name   = "match-stats-cleanrooms-member-access"
  role   = aws_iam_role.cleanrooms.id
  policy = data.aws_iam_policy_document.cleanrooms_access.json
}
