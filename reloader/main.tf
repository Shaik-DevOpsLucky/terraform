locals {
  reloader_name = "reloader"
}

resource "kubernetes_namespace" "reloader" {
  metadata {
    name = "reloader"
    labels = {
      "role" = "reloader"
    }
  }
}

resource "helm_release" "reloader" {
  name      = local.reloader_name
  chart     = "../helm-charts/reloader" # Path to the chart on your local machine
  namespace = kubernetes_namespace.reloader.metadata[0].name
  depends_on = [
    kubernetes_namespace.reloader
  ]
}
