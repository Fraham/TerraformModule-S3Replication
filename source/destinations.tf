
locals {
    eu_north_1_buckets = { for k, v in var.replicas : k => v if v.region == "eu-north-1" } 
    ap_south_1_buckets = { for k, v in var.replicas : k => v if v.region == "ap-south-1" } 
    eu_west_3_buckets = { for k, v in var.replicas : k => v if v.region == "eu-west-3" } 
    eu_west_2_buckets = { for k, v in var.replicas : k => v if v.region == "eu-west-2" } 
    eu_west_1_buckets = { for k, v in var.replicas : k => v if v.region == "eu-west-1" } 
    ap_northeast_3_buckets = { for k, v in var.replicas : k => v if v.region == "ap-northeast-3" } 
    ap_northeast_2_buckets = { for k, v in var.replicas : k => v if v.region == "ap-northeast-2" } 
    ap_northeast_1_buckets = { for k, v in var.replicas : k => v if v.region == "ap-northeast-1" } 
    sa_east_1_buckets = { for k, v in var.replicas : k => v if v.region == "sa-east-1" } 
    ca_central_1_buckets = { for k, v in var.replicas : k => v if v.region == "ca-central-1" } 
    ap_southeast_1_buckets = { for k, v in var.replicas : k => v if v.region == "ap-southeast-1" } 
    ap_southeast_2_buckets = { for k, v in var.replicas : k => v if v.region == "ap-southeast-2" } 
    eu_central_1_buckets = { for k, v in var.replicas : k => v if v.region == "eu-central-1" } 
    us_east_1_buckets = { for k, v in var.replicas : k => v if v.region == "us-east-1" } 
    us_east_2_buckets = { for k, v in var.replicas : k => v if v.region == "us-east-2" } 
    us_west_1_buckets = { for k, v in var.replicas : k => v if v.region == "us-west-1" } 
    us_west_2_buckets = { for k, v in var.replicas : k => v if v.region == "us-west-2" }
  
    all_buckets = merge(
        module.destination_eu_north_1,
        module.destination_ap_south_1,
        module.destination_eu_west_3,
        module.destination_eu_west_2,
        module.destination_eu_west_1,
        module.destination_ap_northeast_3,
        module.destination_ap_northeast_2,
        module.destination_ap_northeast_1,
        module.destination_sa_east_1,
        module.destination_ca_central_1,
        module.destination_ap_southeast_1,
        module.destination_ap_southeast_2,
        module.destination_eu_central_1,
        module.destination_us_east_1,
        module.destination_us_east_2,
        module.destination_us_west_1,
        module.destination_us_west_2
    )
  }  
  
provider "aws" {
    region = "eu-north-1"
    alias  = "eu-north-1"
}
 
provider "aws" {
    region = "ap-south-1"
    alias  = "ap-south-1"
}
 
provider "aws" {
    region = "eu-west-3"
    alias  = "eu-west-3"
}
 
provider "aws" {
    region = "eu-west-2"
    alias  = "eu-west-2"
}
 
provider "aws" {
    region = "eu-west-1"
    alias  = "eu-west-1"
}
 
provider "aws" {
    region = "ap-northeast-3"
    alias  = "ap-northeast-3"
}
 
provider "aws" {
    region = "ap-northeast-2"
    alias  = "ap-northeast-2"
}
 
provider "aws" {
    region = "ap-northeast-1"
    alias  = "ap-northeast-1"
}
 
provider "aws" {
    region = "sa-east-1"
    alias  = "sa-east-1"
}
 
provider "aws" {
    region = "ca-central-1"
    alias  = "ca-central-1"
}
 
provider "aws" {
    region = "ap-southeast-1"
    alias  = "ap-southeast-1"
}
 
provider "aws" {
    region = "ap-southeast-2"
    alias  = "ap-southeast-2"
}
 
provider "aws" {
    region = "eu-central-1"
    alias  = "eu-central-1"
}
 
provider "aws" {
    region = "us-east-1"
    alias  = "us-east-1"
}
 
provider "aws" {
    region = "us-east-2"
    alias  = "us-east-2"
}
 
provider "aws" {
    region = "us-west-1"
    alias  = "us-west-1"
}
 
provider "aws" {
    region = "us-west-2"
    alias  = "us-west-2"
}
  
  
module "destination_eu_north_1" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.eu-north-1
    }
  
    for_each = local.eu_north_1_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_ap_south_1" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.ap-south-1
    }
  
    for_each = local.ap_south_1_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_eu_west_3" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.eu-west-3
    }
  
    for_each = local.eu_west_3_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
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
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
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
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_ap_northeast_3" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.ap-northeast-3
    }
  
    for_each = local.ap_northeast_3_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_ap_northeast_2" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.ap-northeast-2
    }
  
    for_each = local.ap_northeast_2_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_ap_northeast_1" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.ap-northeast-1
    }
  
    for_each = local.ap_northeast_1_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_sa_east_1" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.sa-east-1
    }
  
    for_each = local.sa_east_1_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_ca_central_1" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.ca-central-1
    }
  
    for_each = local.ca_central_1_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_ap_southeast_1" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.ap-southeast-1
    }
  
    for_each = local.ap_southeast_1_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_ap_southeast_2" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.ap-southeast-2
    }
  
    for_each = local.ap_southeast_2_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_eu_central_1" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.eu-central-1
    }
  
    for_each = local.eu_central_1_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_us_east_1" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.us-east-1
    }
  
    for_each = local.us_east_1_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_us_east_2" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.us-east-2
    }
  
    for_each = local.us_east_2_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_us_west_1" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.us-west-1
    }
  
    for_each = local.us_west_1_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}
 
module "destination_us_west_2" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.us-west-2
    }
  
    for_each = local.us_west_2_buckets
  
    versioning = {
      enabled = true
    }
  
    bucket        = each.value.bucket_name
    bucket_prefix = lookup(each.value, "bucket_prefix", null)
  
    acl                 = lookup(each.value, "acl", var.acl)
    tags                = lookup(each.value, "tags", var.tags)
    force_destroy       = lookup(each.value, "force_destroy", var.force_destroy)
    acceleration_status = lookup(each.value, "acceleration_status", var.acceleration_status)
    request_payer       = lookup(each.value, "request_payer", var.request_payer)
  
    website                              = lookup(each.value, "website", var.website)
    cors_rule                            = lookup(each.value, "cors_rule", var.cors_rule)
    logging                              = lookup(each.value, "logging", var.logging)
    grant                                = lookup(each.value, "grant", var.grant)
    lifecycle_rule                       = lookup(each.value, "lifecycle_rule", var.lifecycle_rule)
    server_side_encryption_configuration = lookup(each.value, "server_side_encryption_configuration", var.server_side_encryption_configuration)
    object_lock_configuration            = lookup(each.value, "object_lock_configuration", var.object_lock_configuration)
}

