locals {
  ingress_nginx_name = "ingress-nginx"
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "role" = "ingress-nginx"
    }
  }
}

resource "helm_release" "ingress_nginx" {
  name      = local.ingress_nginx_name
  chart     = "../helm-charts/ingress-nginx"
  namespace = kubernetes_namespace.ingress_nginx.metadata[0].name

  set {
    name  = "nameOverride"
    value = local.ingress_nginx_name
  }

  set {
    name  = "fullnameOverride"
    value = local.ingress_nginx_name
  }

  set {
    name  = "namespaceOverride"
    value = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  set {
    name  = "controller.ingressClass"
    value = local.ingress_nginx_name
  }

  set {
    name  = "controller.service.type"
    value = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.ingress_nginx
  ]
}
