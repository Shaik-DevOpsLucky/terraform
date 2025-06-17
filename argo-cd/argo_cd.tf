locals {
  argo_cd_domain = "asseto-dev.beraucoal.co.id"
}

resource "kubernetes_namespace" "argo-cd" {
  metadata {
    name = "argo-cd"
    labels = {
      "role" = "argo-cd"
    }
  }
}

resource "helm_release" "argo-cd" {
  name      = "argo-cd"
  chart     = "../helm-charts/argo-cd" 
  namespace = kubernetes_namespace.argo-cd.metadata[0].name


  set {
    name  = "nameOverride"
    value = "argo-cd"
  }

  set {
    name  = "fullnameOverride"
    value = "argo-cd"
  }

  set {
    name  = "namespaceOverride"
    value = "argo-cd"
  }

  values = [
    file("argo_cd.yaml")
  ]

  set {
    name  = "notifications.secret.create"
    value = "false"
  }

}


output "argo_cd_public_dns" {
  description = "The Argo-CD DNS name"
  value       = local.argo_cd_domain
}
