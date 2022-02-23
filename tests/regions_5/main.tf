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
      rules       = []
    }
    "replica-3" = {
      bucket_name = "fraham-replica-3"
      region      = "ap-south-1"
      rules       = []
    }
    "replica-4" = {
      bucket_name = "fraham-replica-4"
      region      = "eu-north-1"
      rules       = []
    }
    "replica-5" = {
      bucket_name = "fraham-replica-5"
      region      = "us-east-1"
      rules       = []
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