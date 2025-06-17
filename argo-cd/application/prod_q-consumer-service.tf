locals {
  q-consumer-service_argocd_name            = "q-consumer-service"
}

resource "kubernetes_manifest" "q-consumer-service" {
  field_manager {
    force_conflicts = true
  }

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "${local.environment}-${local.q-consumer-service_argocd_name}"
      "namespace" = "argo-cd"
      "labels" = {
        "service"     = local.q-consumer-service_argocd_name
        "environment" = local.environment
      }
    }
    "spec" = {
      "destination" = {
        "namespace" = "backend"
        "server"    = "https://kubernetes.default.svc"
      }
      "project"              = "default"
      "revisionHistoryLimit" = 5
      "source" = {
        "path"           = "apps/q-consumer-service/overlays/dev"
        "repoURL"        = "https://github.com/${local.github_organization}/gitops.git"
        "targetRevision" = "HEAD"
      }
      "syncPolicy" = local.application_sync_policy
    }
  }
}
