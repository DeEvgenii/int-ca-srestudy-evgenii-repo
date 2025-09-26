resource "google_compute_network" "vpc_network" {
    name = var.network_name
    description = "SRE課題サービス用VPC-dev"
    auto_create_subnetworks = false
    routing_mode = "REGIONAL"
    mtu = 1460
}

resource "google_compute_subnetwork" "subnet" {
    name = var.subnet_name
    description = "SRE課題サービス用サブネット"
    region = var.region
    stack_type = "IPV4_ONLY"
    ip_cidr_range = "172.16.0.0/16"
    private_ip_google_access = true
    network = google_compute_network.vpc_network.id
}

resource "google_compute_global_address" "private_ip_range" {
    name = "private-ip-range"
    purpose = "VPC_PEERING"
    address_type = "INTERNAL"
    prefix_length = 16
    network = google_compute_network.vpc_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
    depends_on = [google_compute_global_address.private_ip_range] 
    network = google_compute_network.vpc_network.self_link
    service = "servicenetworking.googleapis.com"
    reserved_peering_ranges = [google_compute_global_address.private_ip_range.name] //google_compute_global_address.private_ip_range.name
}

resource "google_compute_firewall" "allow-http-from-lb" {
    name = "allow-http-from-lb"
    description = "LBからWeb / APサーバへのhttpリクエストを許可"
    network = google_compute_network.vpc_network.name
    priority = 1000
    direction = "INGRESS"
    allow {
        protocol = "tcp"
        ports = ["80"]
    }
    target_tags = ["nginx"]
    source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}

resource "google_compute_firewall" "allow_ssh_via_iap" {
    name = "allow-ssh-via-iap"
    description = "IAP経由Web / APサーバへのsshを許可"
    network = google_compute_network.vpc_network.name
    priority = 1010
    direction = "INGRESS"
    allow {
        protocol = "tcp"
        ports = ["22"]
    }
    target_tags = ["nginx"]
    source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_address" "nat_ip" {
    name = "nat-static-ip-address"
    region = var.region
}

resource "google_compute_router" "router" {
    name = "nat-router-dev"
    network = google_compute_network.vpc_network.id
    region = var.region
}

resource "google_compute_router_nat" "nat_gateway" {
    name = "nat-gateway-dev"
    router = google_compute_router.router.name
    region = google_compute_router.router.region
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    nat_ip_allocate_option = "MANUAL_ONLY"

    nat_ips = [google_compute_address.nat_ip.self_link]
}
