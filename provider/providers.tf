# Configure your AWS credentials via environment variables, AWS profile, or IAM role.
# The region is fixed - the Roqad collaboration lives in eu-west-1.

provider "aws" {
  region = "eu-west-1"
}

provider "awscc" {
  region = "eu-west-1"
}
