############### S3 BUCKET #############################

# policy config is taken from aws documents 

# https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html

resource "aws_s3_bucket" "web_bucket" {
  bucket = local.s3_bucket_name
  acl    = "private"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_elb_service_account.root.arn}"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",
      "Resource": "arn:aws:s3:::${local.s3_bucket_name}"
    }
  ]
}
    POLICY
}

################################################## IAM #########################################################

# IAM Role

resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# IAM INSTANCE PROFILE

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name
}

# IAM role Policy

resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = [
            "arn:aws:s3:::${local.s3_bucket_name}",
            "arn:aws:s3:::${local.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# Resource: aws_s3_bucket_object to upload files in s3 bucket

resource "aws_s3_bucket_object" "graphic" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/website/logo_Vert.png"
  source = "./website/logo_Vert.png"
}

resource "aws_s3_bucket_object" "website" {
  bucket = aws_s3_bucket.web_bucket.bucket
  key    = "/website/index.html"          
  source = "./website/index.html"
}

