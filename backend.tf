terraform {
  backend "s3" {
    bucket = "tf-join-backend"
    key    = "tools/state"
    region = "us-east-1"
  }
}
