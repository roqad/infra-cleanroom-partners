output "membership_id" {
  description = "Your Clean Rooms membership ID. Share this with Roqad to confirm your setup is complete."
  value       = awscc_cleanrooms_membership.this.membership_identifier
}

output "cleanrooms_role_arn" {
  description = "IAM role ARN assumed by the Clean Rooms service to read your data."
  value       = aws_iam_role.cleanrooms.arn
}
