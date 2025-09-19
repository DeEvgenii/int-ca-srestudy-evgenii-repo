resource "google_compute_security_policy" "waf_policy" {
    project = var.project_id
    name = "default-security-policy-for-backend-service-nginx-back-dev"
    description = "WAFポリシー"
    rule {
        action = "deny(403)"
        priority = 1000
        match {
            expr {
                expression = "evaluatePreconfiguredExpr('sqli-stable')"
            }
        }
        description = "SQLインジェクションをブロック"
    }

    rule {
        action = "deny(403)"
        priority = 1100
        match {
            expr {
                expression = "evaluatePreconfiguredExpr('xss-stable')"
            }
        }
        description = "XSS攻撃をブロック"
    }

    rule {
        action = "allow"
        priority = 2147483647
        match {
            versioned_expr = "SRC_IPS_V1"
            config {
                src_ip_ranges = ["*"]
            }
        }
    }
}

resource "google_compute_managed_ssl_certificate" "managed_ssl_cert" {
    project = var.project_id
    name = "nginx-lb-ssl-cert-dev"
    managed {
        domains = ["evgenii-nginx-dev.sandbox.cloud-ace.dev"]
    }
}

resource "google_compute_global_address" "lb_ip_address" {
    name = "nginx-lb-ip"
}

resource "google_compute_backend_service" "nginx_backend_service" {
    name = "nginx-back-dev"
    project = var.project_id
    protocol = "HTTP"
    load_balancing_scheme = "EXTERNAL"
    connection_draining_timeout_sec = 300
    enable_cdn = false
    security_policy = google_compute_security_policy.waf_policy.id
    health_checks = [var.health_check_id]
    backend {
        group = var.mig_id
    }
}

resource "google_compute_url_map" "default_url_map" {
    name = "default-url-map-dev"
    project = var.project_id
    default_service = google_compute_backend_service.nginx_backend_service.id    
}

resource "google_compute_target_https_proxy" "https_proxy" {
    name = "nginx-lb-https-proxy-dev"
    project = var.project_id
    url_map = google_compute_url_map.default_url_map.id
    ssl_certificates = [google_compute_managed_ssl_certificate.managed_ssl_cert.id]
}

resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
    name = "nginx-lb-dev"
    project = var.project_id
    ip_protocol = "TCP"
    load_balancing_scheme = "EXTERNAL"
    port_range = "443"
    target = google_compute_target_https_proxy.https_proxy.id
    ip_address = google_compute_global_address.lb_ip_address.address
    network_tier = "PREMIUM"
}