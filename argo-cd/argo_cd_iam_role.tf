data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "asseto-dev"
    key    = "eks/terraform.tfstate"
    region = "ap-southeast-5"
    skip_region_validation = true
  }
}


resource "aws_iam_role" "argocd_role" {
  name               = "Dev-ArgoCDRole"
  path               = "/"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Principal": {
                "Federated": "arn:aws:iam::359526746093:oidc-provider/${data.terraform_remote_state.eks.outputs.oidc_provider_url}"
            },
            "Condition": {
                "ForAllValues:StringEquals": {
                    "${data.terraform_remote_state.eks.outputs.oidc_provider_url}:sub": [
                        "system:serviceaccount:argo-cd:argocd-server",
                        "system:serviceaccount:argo-cd:argocd-application-controller"
                    ]
                    "${data.terraform_remote_state.eks.outputs.oidc_provider_url}:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
})
}

resource "aws_iam_policy" "argocd_policy" {
  name        = "Dev-ArgoCDPolicy"
  path        = "/"
  description = "Dev-ArgoCD Server SA Policy"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "*"
        }
    ]
  }) 
}

resource "aws_iam_role_policy_attachment" "argocd_policy_attachment" {
  role       = aws_iam_role.argocd_role.name
  policy_arn = aws_iam_policy.argocd_policy.arn
}
