locals {
  all_rules = flatten([
    for region_buckets_key, region_buckets_value in local.all_buckets : [
      for bucket_key, bucket_value in(length(lookup(var.replicas[region_buckets_key], "rules", [])) > 0 ? var.replicas[region_buckets_key].rules : [{}]) :
      merge(
        { id = "${region_buckets_key}${bucket_key}" },
        { priority = "${index(keys(local.all_buckets), region_buckets_key)}${bucket_key}" },
        { status = "Enabled" },
        bucket_value,
        { destination = merge({ bucket = region_buckets_value.s3_bucket_arn }, lookup(bucket_value, "destination", null)) }
      )
    ]
  ])
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

module "source" {
  source = "terraform-aws-modules/s3-bucket/aws"


  bucket        = var.bucket_name
  bucket_prefix = var.bucket_prefix

  versioning = {
    enabled = true # replication requires versioning to be enabled
  }

  acl                                  = var.acl
  tags                                 = var.tags
  force_destroy                        = var.force_destroy
  acceleration_status                  = var.acceleration_status
  request_payer                        = var.request_payer
  website                              = var.website
  cors_rule                            = var.cors_rule
  logging                              = var.logging
  grant                                = var.grant
  lifecycle_rule                       = var.lifecycle_rule
  server_side_encryption_configuration = var.server_side_encryption_configuration
  object_lock_configuration            = var.object_lock_configuration

  replication_configuration = {
    role  = aws_iam_role.replication.arn
    rules = local.all_rules
  }
}
