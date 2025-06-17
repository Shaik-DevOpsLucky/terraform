locals {
  q-analysis-service_argocd_name            = "q-analysis-service"
}

resource "kubernetes_manifest" "q-analysis-service" {
  field_manager {
    force_conflicts = true
  }

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "${local.environment}-${local.q-analysis-service_argocd_name}"
      "namespace" = "argo-cd"
      "labels" = {
        "service"     = local.q-analysis-service_argocd_name
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
        "path"           = "apps/q-analysis-service/overlays/dev"
        "repoURL"        = "https://github.com/${local.github_organization}/gitops.git"
        "targetRevision" = "HEAD"
      }
      "syncPolicy" = local.application_sync_policy
    }
  }
}
