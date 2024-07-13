data "terraform_remote_state" "order_processing" {
  backend = "s3"
  config = {
    bucket = "global-infra-state"
    key    = "global-infra/terraform.tfstate"
    region = "eu-central-1"
  }
}
