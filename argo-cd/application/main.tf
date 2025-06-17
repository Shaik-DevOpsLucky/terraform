locals {
  environment = lookup(var.environment, terraform.workspace)
  application_sync_policy = {
    automated = {
      allowEmpty = true
      prune      = true
      selfHeal   = true
    },
    syncOptions = [
      "CreateNamespace=true",
      "ApplyOutOfSyncOnly=true",
    ]
  }
  github_organization                               = "NXT-Asseto"
}
