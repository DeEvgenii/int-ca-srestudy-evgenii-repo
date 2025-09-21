output "lb_ip" {
    description = "ロードバランサのIP"
    value       = google_compute_global_address.lb_ip_address.address
}
