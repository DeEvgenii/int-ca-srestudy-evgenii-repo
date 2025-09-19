resource "google_sql_database_instance" "database_instance" {
    depends_on = [var.service_networking_connection_id]
    project = var.project_id
    name = "db-dev"
    database_version = "MYSQL_8_0"
    region = var.region

    deletion_protection = false
    settings {
        tier = "db-f1-micro"
        availability_type = "ZONAL"
        disk_type = "PD_HDD"
        disk_size = 10
        disk_autoresize = false
        ip_configuration {
            ipv4_enabled = false
            private_network = var.network_self_link
        }
        backup_configuration {
            enabled = true
            binary_log_enabled = true
            start_time = "18:00"
            location = var.region
            backup_retention_settings {
                retained_backups = 7
            }
        }
        database_flags {
            name = "cloudsql_iam_authentication"
            value = "on"
        }
    }
    
}

data "google_compute_default_service_account" "default" {
}

resource "google_sql_user" "database_user" {
    depends_on = [google_sql_database_instance.database_instance]
    project = var.project_id
    instance = google_sql_database_instance.database_instance.name
    name = "${data.google_compute_default_service_account.default.email}"
    type = "CLOUD_IAM_SERVICE_ACCOUNT"
}