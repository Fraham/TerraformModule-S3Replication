output "replica_buckets" {
    value = local.all_buckets
}

output "source_bucket" {
    value = aws_s3_bucket.source
}

output "all_rules" {
    value = local.all_rules
}