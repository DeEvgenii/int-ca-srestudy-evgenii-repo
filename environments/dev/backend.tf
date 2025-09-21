terraform {
    backend "gcs" {
        bucket = "ca-srestudy-evgenii-lift-mng-tf-state"
        prefix = "terraform/state"
    }
}
