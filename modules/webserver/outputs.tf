output "mig_id" {
    description = "インスタンスグループのID"
    value = google_compute_region_instance_group_manager.nginx_mig.instance_group
}

output "health_check_id" {
    description = "devヘルスチェックのID"
    value = google_compute_health_check.nginx_http_health_check.id
}
