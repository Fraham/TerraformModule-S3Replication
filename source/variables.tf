variable "bucket_name" {
  type = string
}

variable "replicas" {
  type = map(object({
    bucket_name = string
    region      = string
  }))
}
