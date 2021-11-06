locals {
  eu_west_1_buckets = { for k, v in var.replicas : k => v if v.region == "eu-west-1" }
  eu_west_2_buckets = { for k, v in var.replicas : k => v if v.region == "eu-west-2" }

  all_buckets = merge({ for k, v in aws_s3_bucket.destination_eu_west_1 : k => { bucket_arn = v.arn } },
  { for k, v in aws_s3_bucket.destination_eu_west_2 : k => { bucket_arn = v.arn } })
}

provider "aws" {
  region = "eu-west-1"
  alias  = "eu-west-1"
}

provider "aws" {
  region = "eu-west-2"
  alias  = "eu-west-2"
}

resource "aws_iam_role" "replication" {
  name = "${var.bucket_name}-replication"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "${var.bucket_name}-replication"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
         "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.source.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication_destination" {
  for_each = local.all_buckets

  name = "${var.bucket_name}-replication-destination-${each.key}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
      "Effect": "Allow",
      "Resource": "${each.value.bucket_arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}

resource "aws_iam_role_policy_attachment" "replication_destination" {
  for_each = local.all_buckets

  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication_destination[each.key].arn
}

resource "aws_s3_bucket" "destination_eu_west_1" {
  for_each = local.eu_west_1_buckets

  bucket = each.value.bucket_name

  provider = aws.eu-west-1

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "destination_eu_west_2" {
  for_each = local.eu_west_2_buckets

  bucket = each.value.bucket_name

  provider = aws.eu-west-2

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "source" {
  bucket = var.bucket_name

  versioning {
    enabled = true
  }

  replication_configuration {
    role = aws_iam_role.replication.arn

    dynamic "rules" {
      for_each = local.all_buckets

      content {
        id     = rules.key
        status = "Enabled"

        priority = index(keys(local.all_buckets), rules.key)

        filter {
        }
        destination {
          bucket        = rules.value["bucket_arn"]
          storage_class = "STANDARD"
        }
      }
    }
  }
}
