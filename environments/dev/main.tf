terraform {
  required_providers {
    google = { 
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
    project = var.project_id
    region = var.region
}

module "network" {
    source = "../../modules/network"
    region = var.region
}

module "database" {
    source = "../../modules/database"
    project_id = var.project_id
    region = var.region
    network_self_link = module.network.network_self_link
    service_networking_connection_id = module.network.service_networking_connection_id
}

module "webserver" {
    source = "../../modules/webserver"
    region = var.region
    network_id = module.network.network_id
    subnet_id = module.network.subnet_id
}

module "load_balancer" {
    source = "../../modules/load_balancer"
    project_id = var.project_id
    mig_id = module.webserver.mig_id
    health_check_id = module.webserver.health_check_id
}

data "google_compute_default_service_account" "default" {
}

resource "google_project_iam_member" "iap_ssh_access" {
    project = var.project_id
    role = "roles/iap.tunnelResourceAccessor"
    member = "user:demochkin.evgenii@cloud-ace.jp"
}

resource "google_project_iam_member" "compute_to_sql_access" {
    project = var.project_id
    role = "roles/cloudsql.client"
    member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}
