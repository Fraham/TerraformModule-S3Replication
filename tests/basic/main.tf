provider "aws" {
  region = "eu-west-1"
}

module "basic_replica" {
  source = "../../source/"

  bucket_name = "fraham-source"
  replicas = {
    "replica-1" = {
      bucket_name = "fraham-replica-1"
      region      = "eu-west-1"
      rules       = []
    }
    "replica-2" = {
      bucket_name = "fraham-replica-2"
      region      = "eu-west-2"
      rules = [
        {
          destination = {
            storage_class = "STANDARD"
          }
        },
        {
          destination = {
            storage_class = "GLACIER"
          }
        }
      ]
    }
  }
}


output "replica_buckets" {
  value = module.basic_replica.replica_buckets
}

output "source_bucket" {
  value = module.basic_replica.source_bucket
}

output "all_rules" {
  value = module.basic_replica.all_rules
}