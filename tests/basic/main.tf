provider "aws" {
  region = "eu-west-1"
}

module "basic_replica" {
  source = "../../source/"

  bucket_name = "gpye-source"
  replicas = {
    "replica-1" = {
      bucket_name = "gpye-replica-1"
      region      = "eu-west-1"
    }
    "replica-2" = {
      bucket_name = "gpye-replica-2"
      region      = "eu-west-2"
    }
  }
}


output "buckets"{
    value = module.basic_replica.buckets
}