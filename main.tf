provider "aws" {
  region = "us-east-1"
}

module "s3" {
  source = "git@bitbucket.org:mediaiq/iac-terraform-aws-s3.git"
  // inputs for tagging
  mandatory_tags = {
    TEAM        = "devops"
    DEPARTMENT  = "tech"
    OWNER       = "devops"
    FUNCTION    = "test"
    PRODUCT     = "test"
    ENVIRONMENT = "test"
  }
  // inputs for s3
  bucket_name = "miq-iac-test-terraform"
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule = [
    {
      id      = "log"
      enabled = true

      filter = {
        prefix = "log3/"
      }

      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
          }, {
          days          = 60
          storage_class = "GLACIER"
        }
      ]

    },
    {
      id                                     = "log1"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }
    },
    {
      id      = "log2"
      enabled = true

      filter = {
        prefix                   = "log1/"
        object_size_greater_than = 200000
        object_size_less_than    = 500000
        tags = {
          some    = "value"
          another = "value2"
        }
      }

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }
    },
  ]
}

