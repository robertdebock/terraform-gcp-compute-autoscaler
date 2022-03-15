resource "google_compute_autoscaler" "default" {
  name   = "my-autoscaler"
  zone   = "us-central1-f"
  target = google_compute_instance_group_manager.default.id

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}

resource "google_compute_instance_template" "default" {
  name_prefix    = "my-instance-template-"
  machine_type   = "e2-medium"
  can_ip_forward = false

  disk {
    source_image = data.google_compute_image.debian_9.id
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = "${file("script.sh")}"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_target_pool" "default" {
  name = "my-target-pool"
  health_checks = [
    google_compute_http_health_check.default.name,
  ]
}

resource "google_compute_http_health_check" "default" {
  name               = "default"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_instance_group_manager" "default" {
  name = "my-igm"
  zone = "us-central1-f"

  version {
    instance_template  = google_compute_instance_template.default.id
    name               = "primary"
  }

  target_pools       = [google_compute_target_pool.default.id]
  base_instance_name = "default"
}

data "google_compute_image" "debian_9" {
  family  = "debian-9"
  project = "debian-cloud"
}
