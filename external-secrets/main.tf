# Fetch EKS cluster details dynamically
data "aws_eks_cluster" "cluster" {
  name = "asseto-dev" # The EKS cluster name
}

# Fetch authentication token for Kubernetes provider
data "aws_eks_cluster_auth" "auth" {
  name = "asseto-dev" # The EKS cluster name
}

# Kubernetes provider using the EKS cluster endpoint and CA certificate
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data) # Fetch CA cert dynamically
  token                  = data.aws_eks_cluster_auth.token
}

resource "kubernetes_namespace" "external-secrets" {
  metadata {
    name = "external-secrets"
  }
}

resource "aws_iam_role" "external_secrets_role" {
  name = "external-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer}:sub" = "system:serviceaccount:external-secrets:external-secrets"
          }
        }
      }
    ]
  })
}
