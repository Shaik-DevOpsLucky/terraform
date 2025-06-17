# Install Metrics Server via Helm
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.2" # Specify the version you want to install
  namespace  = "kube-system"

  set {
    name  = "ssl"
    value = "false" # Disable SSL for the metrics server
  }

  # Optional: Add a release timeout in case of slow deployments
  timeout = 600

  # Optional: Add specific values for customization if needed
  values = [
    # Custom values can go here if required
  ]

  # Optional: Wait for deployment to complete before Terraform applies other resources
  wait = true
}

# If needed, you can include any additional resources, like service accounts, roles, etc.
