output "replica_buckets" {
    value = local.all_buckets
}

output "source_bucket" {
    value = module.source
}

output "all_rules" {
    value = local.all_rules
}