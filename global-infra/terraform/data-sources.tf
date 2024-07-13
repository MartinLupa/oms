data "terraform_remote_state" "order_processing" {
  backend = "s3"
  config = {
    bucket = "order-processing-state"
    key    = "./terraform.tfstate"
    region = "eu-central-1"
  }
}
