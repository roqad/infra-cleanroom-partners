resource "aws_iam_user" "upload" {
  name = "cleanroom-customer-${local.customer_name}"
  path = "/cleanroom/customers/"
}

resource "aws_iam_access_key" "upload" {
  user = aws_iam_user.upload.name
}

resource "aws_iam_user_policy" "upload" {
  name = "cleanroom-customer-${local.customer_name}-upload"
  user = aws_iam_user.upload.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
        Resource = "arn:aws:s3:::${local.s3_bucket}/${local.s3_prefix}*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::${local.s3_bucket}"
        Condition = {
          StringLike = {
            "s3:prefix" = "${local.s3_prefix}*"
          }
        }
      }
    ]
  })
}
