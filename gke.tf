# Deploy GKE

resource "google_container_cluster" "gke" {
  name     = "gke-cluster"
  location = var.gcp_region
  project  = local.gcp_project_id

  initial_node_count = var.node_count / 2

  node_config {
    machine_type = var.gcp_node_size
  }

  node_locations = ["${var.gcp_region}-c", "${var.gcp_region}-b"]

  networking_mode = "VPC_NATIVE"
  network         = module.gcp_vpc.network_self_link
  subnetwork      = module.gcp_vpc.subnets_ids[1]

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod"
    services_secondary_range_name = "service"
  }

  depends_on = [
    module.gcp_vpc
  ]
}


resource "null_resource" "get_gke_creds" {
  triggers = {
    label_fingerprint = google_container_cluster.gke.label_fingerprint
  }
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials gke-cluster --region ${var.gcp_region}"
  }
  depends_on = [
    google_container_cluster.gke
  ]
}