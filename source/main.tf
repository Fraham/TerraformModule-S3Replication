locals {
  eu_west_1_buckets = { for k, v in var.replicas : k => v if v.region == "eu-west-1" }
  eu_west_2_buckets = { for k, v in var.replicas : k => v if v.region == "eu-west-2" }

  all_buckets = merge(
    module.destination_eu_west_1,
    module.destination_eu_west_2
  )

  all_rules = flatten([
    for bk, bv in local.all_buckets : [
      for rk, rb in(length(lookup(var.replicas[bk], "rules", [])) > 0 ? var.replicas[bk].rules : [{}]) :
      merge(
        { id = "${bk}${rk}" },
        { priority = "${index(keys(local.all_buckets), bk)}${rk}" },
        { status = "Enabled" },
        rb,
        { destination = merge({bucket = bv.s3_bucket_arn}, lookup(rb, "destination", null)) }
      )
    ]
    ]
  )
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
        "${module.source.s3_bucket_arn}"
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
        "${module.source.s3_bucket_arn}/*"
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
      "Resource": "${each.value.s3_bucket_arn}/*"
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

module "destination_eu_west_1" {
  source = "terraform-aws-modules/s3-bucket/aws"

  providers = {
    aws = aws.eu-west-1
  }

  for_each = local.eu_west_1_buckets

  versioning = {
    enabled = true
  }

  bucket        = each.value.bucket_name
  bucket_prefix = lookup(each.value, "bucket_prefix", null)

  acl = var.acl

  tags                = var.tags
  force_destroy       = var.force_destroy
  acceleration_status = var.acceleration_status
  request_payer       = var.request_payer

  website = var.website

  cors_rule = var.cors_rule

  logging = var.logging

  grant = var.grant

  lifecycle_rule = var.lifecycle_rule

  server_side_encryption_configuration = var.server_side_encryption_configuration

  object_lock_configuration = var.object_lock_configuration
}

module "destination_eu_west_2" {
  source = "terraform-aws-modules/s3-bucket/aws"

  providers = {
    aws = aws.eu-west-2
  }

  for_each = local.eu_west_2_buckets

  versioning = {
    enabled = true
  }

  bucket        = each.value.bucket_name
  bucket_prefix = lookup(each.value, "bucket_prefix", null)

  acl = var.acl

  tags                = var.tags
  force_destroy       = var.force_destroy
  acceleration_status = var.acceleration_status
  request_payer       = var.request_payer

  website = var.website

  cors_rule = var.cors_rule

  logging = var.logging

  grant = var.grant

  lifecycle_rule = var.lifecycle_rule

  server_side_encryption_configuration = var.server_side_encryption_configuration

  object_lock_configuration = var.object_lock_configuration
}

module "source" {
  source = "terraform-aws-modules/s3-bucket/aws"


  bucket        = var.bucket_name
  bucket_prefix = var.bucket_prefix

  versioning = {
    enabled = true
  }

  acl = var.acl

  tags                = var.tags
  force_destroy       = var.force_destroy
  acceleration_status = var.acceleration_status
  request_payer       = var.request_payer

  website = var.website

  cors_rule = var.cors_rule

  logging = var.logging

  grant = var.grant

  lifecycle_rule = var.lifecycle_rule

  server_side_encryption_configuration = var.server_side_encryption_configuration

  object_lock_configuration = var.object_lock_configuration

  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = local.all_rules
  }
}
