locals {
  iot-device-search-service_argocd_name            = "iot-device-search-service"
}

resource "kubernetes_manifest" "iot-device-search-service" {
  field_manager {
    force_conflicts = true
  }

  manifest = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "${local.environment}-${local.iot-device-search-service_argocd_name}"
      "namespace" = "argo-cd"
      "labels" = {
        "service"     = local.iot-device-search-service_argocd_name
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
        "path"           = "apps/iot-device-search-service/overlays/dev"
        "repoURL"        = "https://github.com/${local.github_organization}/gitops.git"
        "targetRevision" = "aws-uat"
      }
      "syncPolicy" = local.application_sync_policy
    }
  }
}
