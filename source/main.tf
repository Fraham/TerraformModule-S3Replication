locals {
  eu_west_1_buckets = { for k, v in var.replicas : k => v if v.region == "eu-west-1" }
  eu_west_2_buckets = { for k, v in var.replicas : k => v if v.region == "eu-west-2" }

  all_buckets = merge(
    module.destination_eu_west_1,
    module.destination_eu_west_2
  )

  all_rules = flatten([
    for bk, bv in local.all_buckets : [
      for rk, rb in (length(lookup(var.replicas[bk], "rules", [])) > 0 ? var.replicas[bk].rules : [{}]) :
        merge(
          {bucket_arn = bv.s3_bucket_arn},
          rb
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

  bucket = each.value.bucket_name
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

  bucket = each.value.bucket_name
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

resource "aws_s3_bucket" "source" {
  bucket = var.bucket_name
  bucket_prefix = var.bucket_prefix

  versioning {
    enabled = true
  }

  acl = var.acl != "null" ? var.acl : null

  tags                = var.tags
  force_destroy       = var.force_destroy
  acceleration_status = var.acceleration_status
  request_payer       = var.request_payer

  dynamic "website" {
    for_each = length(keys(var.website)) == 0 ? [] : [var.website]

    content {
      index_document           = lookup(website.value, "index_document", null)
      error_document           = lookup(website.value, "error_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  dynamic "cors_rule" {
    for_each = try(jsondecode(var.cors_rule), var.cors_rule)

    content {
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }

  dynamic "logging" {
    for_each = length(keys(var.logging)) == 0 ? [] : [var.logging]

    content {
      target_bucket = logging.value.target_bucket
      target_prefix = lookup(logging.value, "target_prefix", null)
    }
  }

  dynamic "grant" {
    for_each = try(jsondecode(var.grant), var.grant)

    content {
      id          = lookup(grant.value, "id", null)
      type        = grant.value.type
      permissions = grant.value.permissions
      uri         = lookup(grant.value, "uri", null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)

    content {
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(lifecycle_rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(lifecycle_rule.value, "noncurrent_version_expiration", {})]

        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])

        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }


  replication_configuration {
    role = aws_iam_role.replication.arn

      dynamic "rules" {
        for_each = local.all_rules

        content {
          id                               = index(local.all_rules, rules.value)
          priority                         = index(local.all_rules, rules.value)
          prefix                           = lookup(rules.value, "prefix", null)
          delete_marker_replication_status = lookup(rules.value, "delete_marker_replication_status", null)
          status                           = lookup(rules.value, "status", "Enabled")

          dynamic "destination" {
            for_each = length(keys(lookup(rules.value, "destination", {}))) == 0 ? [{}] : [lookup(rules.value, "destination", {})]

            content {
              bucket        = rules.value["bucket_arn"]
              storage_class      = lookup(destination.value, "storage_class", null)
              replica_kms_key_id = lookup(destination.value, "replica_kms_key_id", null)
              account_id         = lookup(destination.value, "account_id", null)

              # dynamic "access_control_translation" {
              #   for_each = length(keys(lookup(destination.value, "access_control_translation", {}))) == 0 ? [] : [lookup(destination.value, "access_control_translation", {})]

              #   content {
              #     owner = access_control_translation.value.owner
              #   }
              # }
            }
          }

          dynamic "source_selection_criteria" {
            for_each = length(keys(lookup(rules.value, "source_selection_criteria", {}))) == 0 ? [] : [lookup(rules.value, "source_selection_criteria", {})]

            content {

              dynamic "sse_kms_encrypted_objects" {
                for_each = length(keys(lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {}))) == 0 ? [] : [lookup(source_selection_criteria.value, "sse_kms_encrypted_objects", {})]

                content {

                  enabled = sse_kms_encrypted_objects.value.enabled
                }
              }
            }
          }

          # Send empty map if `filter` is an empty map or absent entirely
          dynamic "filter" {
            for_each = length(keys(lookup(rules.value, "filter", {}))) == 0 ? [{}] : []

            content {}
          }

          # Send `filter` if it is present and has at least one field
          dynamic "filter" {
            for_each = length(keys(lookup(rules.value, "filter", {}))) != 0 ? [lookup(rules.value, "filter", {})] : []

            content {
              prefix = lookup(filter.value, "prefix", null)
              tags   = lookup(filter.value, "tags", null)
            }
          }

        }
      }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = length(keys(var.server_side_encryption_configuration)) == 0 ? [] : [var.server_side_encryption_configuration]

    content {

      dynamic "rule" {
        for_each = length(keys(lookup(server_side_encryption_configuration.value, "rule", {}))) == 0 ? [] : [lookup(server_side_encryption_configuration.value, "rule", {})]

        content {
          bucket_key_enabled = lookup(rule.value, "bucket_key_enabled", null)

          dynamic "apply_server_side_encryption_by_default" {
            for_each = length(keys(lookup(rule.value, "apply_server_side_encryption_by_default", {}))) == 0 ? [] : [
            lookup(rule.value, "apply_server_side_encryption_by_default", {})]

            content {
              sse_algorithm     = apply_server_side_encryption_by_default.value.sse_algorithm
              kms_master_key_id = lookup(apply_server_side_encryption_by_default.value, "kms_master_key_id", null)
            }
          }
        }
      }
    }
  }

  dynamic "object_lock_configuration" {
    for_each = length(keys(var.object_lock_configuration)) == 0 ? [] : [var.object_lock_configuration]

    content {
      object_lock_enabled = object_lock_configuration.value.object_lock_enabled

      dynamic "rule" {
        for_each = length(keys(lookup(object_lock_configuration.value, "rule", {}))) == 0 ? [] : [lookup(object_lock_configuration.value, "rule", {})]

        content {
          default_retention {
            mode  = lookup(lookup(rule.value, "default_retention", {}), "mode")
            days  = lookup(lookup(rule.value, "default_retention", {}), "days", null)
            years = lookup(lookup(rule.value, "default_retention", {}), "years", null)
          }
        }
      }
    }
  }
}
