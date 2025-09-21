resource "google_compute_resource_policy" "nginx_snapshot_schedule" {
    name = "nginx-snapshot-schedule-dev"
    region = var.region
    description = "Web / APサーバのディスクのスナップショットスケジュール"
    snapshot_schedule_policy {
      schedule {
        daily_schedule {
          days_in_cycle = 1
          start_time = "18:00"
        }
      }
      retention_policy {
        max_retention_days = 7
        on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
      }
    }
}

resource "google_compute_region_instance_template" "nginx_tmp_dev" {
    name = "nginx-tmp-dev"
    description = "Web / APサーバ"
    machine_type = "e2-small"
    region = var.region
    disk {
        source_image = "debian-cloud/debian-11"
        disk_type = "pd-balanced"
        disk_size_gb = 10
        auto_delete = true
        resource_policies = [google_compute_resource_policy.nginx_snapshot_schedule.id]
    }
    network_interface {
        network = var.network_id
        subnetwork = var.subnet_id
        stack_type = "IPV4_ONLY"
    }

    metadata = {
        startup-script = file("${path.module}/startup.sh")
    }
    
    tags = ["nginx"]
    scheduling {
        automatic_restart = true
        on_host_maintenance = "MIGRATE"
    }
    service_account {
        scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }
    shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm = true
        enable_integrity_monitoring = true
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "google_compute_health_check" "nginx_http_health_check" {
    name = "nginx-lb-http-helth-check-dev"
    check_interval_sec = 10
    timeout_sec = 10
    healthy_threshold = 3
    unhealthy_threshold = 5
    http_health_check {
        request_path = "/"
        port = 80
    }
}

resource "google_compute_region_instance_group_manager" "nginx_mig" {
    name = "nginx-mig-dev"
    description = "Web / APサーバ"
    base_instance_name = "nginx-dev"
    region = var.region
    distribution_policy_zones = ["${var.region}-a", "${var.region}-b", "${var.region}-c"]
    version {
        instance_template = google_compute_region_instance_template.nginx_tmp_dev.id
    }
    named_port {
        name = "http"
        port = 80
    }
    auto_healing_policies {
        health_check = google_compute_health_check.nginx_http_health_check.id
        initial_delay_sec = 300
    }
    
}

resource "google_compute_region_autoscaler" "nginx_autoscaler" {
    name = "nginx-autoscaler-dev"
    region = var.region
    target = google_compute_region_instance_group_manager.nginx_mig.id
    autoscaling_policy {
        max_replicas = 3
        min_replicas = 2
        cooldown_period = 60
        cpu_utilization {
            target = 0.7
        }
    }
}
