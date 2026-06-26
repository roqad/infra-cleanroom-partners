# IAM role assumed by the Clean Rooms service to read your Glue catalog and S3 data.
# Covers all tables defined in local.tables (config.tf).

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
  name                 = local.iam_role_name
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
    resources = [for t in local.tables : "arn:aws:s3:::${t.s3_bucket}/${t.s3_key_prefix}*"]
  }

  statement {
    sid       = "S3ListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = distinct([for t in local.tables : "arn:aws:s3:::${t.s3_bucket}"])
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = [for t in local.tables : "${t.s3_key_prefix}*"]
    }
  }

  statement {
    sid    = "GlueRead"
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
    resources = concat(
      ["arn:aws:glue:${local.region}:${data.aws_caller_identity.current.account_id}:catalog"],
      distinct([for t in local.tables : "arn:aws:glue:${local.region}:${data.aws_caller_identity.current.account_id}:database/${t.glue_database}"]),
      [for t in local.tables : "arn:aws:glue:${local.region}:${data.aws_caller_identity.current.account_id}:table/${t.glue_database}/${t.glue_table}"],
    )
  }
}

resource "aws_iam_role_policy" "cleanrooms_access" {
  name   = "${local.iam_role_name}-access"
  role   = aws_iam_role.cleanrooms.id
  policy = data.aws_iam_policy_document.cleanrooms_access.json
}
