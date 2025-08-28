remote_state {
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "pamfes-state-bucket"
    key = "${path_relative_to_include()}/tofu.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "pamfes-lock-table"
    s3_bucket_tags = {
      name = "pam-fes-infra-remote-state-bucket"
    }

  }
}

