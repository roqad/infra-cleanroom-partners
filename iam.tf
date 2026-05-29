# IAM role assumed by the Clean Rooms service to read your Glue catalog and S3 data.
# Scoped to the single table and S3 prefix in config.tf — nothing else.

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
    sid    = "S3Read"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    resources = [local.prefix_arn]
  }

  statement {
    sid     = "S3ListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [local.bucket_arn]
  }

  statement {
    sid    = "GlueReadTable"
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
    resources = [
      "arn:aws:glue:${local.region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${local.region}:${data.aws_caller_identity.current.account_id}:database/${local.glue_database}",
      "arn:aws:glue:${local.region}:${data.aws_caller_identity.current.account_id}:table/${local.glue_database}/${local.glue_table}",
    ]
  }
}

resource "aws_iam_role_policy" "cleanrooms_access" {
  name   = "match-stats-cleanrooms-member-access"
  role   = aws_iam_role.cleanrooms.id
  policy = data.aws_iam_policy_document.cleanrooms_access.json
}
