# Configure your AWS credentials via environment variables, AWS profile, or IAM role.
# The region must stay eu-west-1 — that is where the Roqad collaboration lives.

provider "aws" {
  region = var.region
}

provider "awscc" {
  region = var.region
}
