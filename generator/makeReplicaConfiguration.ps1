function replaceRegion {
  param (
    $region,
    $text
  )

  return ($text -replace "{{REGION}}", $region) -replace "{{REGION_}}", ($region -replace "-", "_")
}

$providerTemplate = '
provider "aws" {
    region = "{{REGION}}"
    alias  = "{{REGION}}"
}
'

$bucketListTemplate = '
    {{REGION_}}_buckets = { for k, v in var.replicas : k => v if v.region == "{{REGION}}" }'

$regionBucketsTemplate = '
        module.destination_{{REGION_}}'

$bucketTemplate = '
module "destination_{{REGION_}}" {
    source = "terraform-aws-modules/s3-bucket/aws"
  
    providers = {
      aws = aws.{{REGION}}
    }
  
    for_each = local.{{REGION_}}_buckets
  
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
'

$fileTemplate = '
locals {{{BUCKET_LISTS}}
  
    all_buckets = merge({{REGION_BUCKETS}}
    )
  }  
  {{PROVIDERS}}  
  {{BUCKETS}}'

$providers = @()
$bucketLists = @()
$regionBuckets = @()
$buckets = @()

$regions = @() # if only a subset of regionns is required, add their names here,

if ($regions.Count -eq 0) {
    $regions = (aws ec2 describe-regions --query "Regions[].{Name:RegionName}" --output json) | ConvertFrom-Json | ForEach-Object { return $_.Name }
}

foreach ($region in $regions) {
    $providers += replaceRegion -text $providerTemplate -region $region
    $bucketLists += replaceRegion -text $bucketListTemplate -region $region
    $regionBuckets += replaceRegion -text $regionBucketsTemplate -region $region
    $buckets += replaceRegion -text $bucketTemplate -region $region    
}

$fileTemplate = $fileTemplate -replace "{{BUCKET_LISTS}}", $bucketLists
$fileTemplate = $fileTemplate -replace "{{REGION_BUCKETS}}", ($regionBuckets -join ',')
$fileTemplate = $fileTemplate -replace "{{PROVIDERS}}", $providers
$fileTemplate = $fileTemplate -replace "{{BUCKETS}}", $buckets

$fileTemplate | Out-File -FilePath "$($PSScriptRoot)/../source/destinations.tf"