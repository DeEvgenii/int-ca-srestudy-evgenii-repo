output "network_id" {
    value = google_compute_network.vpc_network.id
    description = "VPCネットワークID"
}

output "subnet_id" {
    value = google_compute_subnetwork.subnet.id
    description = "サブネットID"
}

output "service_networking_connection_id" {
    value = google_service_networking_connection.private_vpc_connection.id
    description = "VPCコネクションID"
}

output "network_self_link" {
  description = "The self-link of the VPC network."
  value       = google_compute_network.vpc_network.self_link
}