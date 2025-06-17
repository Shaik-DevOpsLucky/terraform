locals {
  event-trigger-service_argocd_name            = "event-trigger-service"
}

resource "kubernetes_manifest" "event-trigger-service" {
  field_manager {
    force_conflicts = true
  }

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "${local.environment}-${local.event-trigger-service_argocd_name}"
      "namespace" = "argo-cd"
      "labels" = {
        "service"     = local.event-trigger-service_argocd_name
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
        "path"           = "apps/event-trigger-service/overlays/dev"
        "repoURL"        = "https://github.com/${local.github_organization}/gitops.git"
        "targetRevision" = "aws-uat"
      }
      "syncPolicy" = local.application_sync_policy
    }
  }
}
