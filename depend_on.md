## how to use depends_on module? how it works and when to use?
---
Great question 👍
`depends_on` with **Terraform modules** is an **important concept** and often misunderstood. I’ll explain it **clearly**, with **how it works, when to use it, and real examples**.

---

# Terraform `depends_on` with Modules – Explained Clearly 🚀

## 1️⃣ What is `depends_on`?

`depends_on` tells Terraform:

> **“Create this resource or module ONLY after the listed resources/modules are created.”**

Terraform usually figures dependencies automatically, but sometimes **it cannot** — that’s when `depends_on` is needed.

---

## 2️⃣ How Terraform Normally Handles Dependencies (Implicit)

Terraform builds a **dependency graph**.

### Example (No depends_on needed)

```hcl
resource "aws_instance" "app" {
  subnet_id = aws_subnet.app.id
}
```

👉 Because `subnet_id` references `aws_subnet.app.id`, Terraform **automatically knows** the order.

---

## 3️⃣ Why `depends_on` is Needed for Modules

Modules are **black boxes** to Terraform.
If **no output is referenced**, Terraform may not know the correct order.

---

## 4️⃣ Syntax: `depends_on` with Module

```hcl
module "eks" {
  source = "./modules/eks"
}

module "addons" {
  source = "./modules/eks-addons"

  depends_on = [
    module.eks
  ]
}
```

👉 Terraform will:

1. Create `module.eks`
2. Then create `module.addons`

---

## 5️⃣ How `depends_on` Works Internally 🧠

* Terraform creates a **dependency edge**
* Module B waits until **all resources** inside Module A are created
* Works at **module level**, not individual resource level

📌 Important:

> `depends_on` does **NOT** pass values
> It only controls **order**

---

## 6️⃣ Real-World Examples (Very Important)

---

### Example 1: VPC → EKS (Classic Case)

```hcl
module "vpc" {
  source = "./modules/vpc"
}

module "eks" {
  source = "./modules/eks"

  depends_on = [
    module.vpc
  ]
}
```

✔ Ensures VPC exists before EKS
✔ Even if outputs are not referenced

---

### Example 2: EKS → Helm / ArgoCD

```hcl
module "eks" {
  source = "./modules/eks"
}

module "argocd" {
  source = "./modules/argocd"

  depends_on = [
    module.eks
  ]
}
```

✔ EKS cluster must be ready
✔ Kubernetes API must exist before deploying apps

---

### Example 3: IAM Role → Service (Hidden Dependency)

```hcl
module "iam" {
  source = "./modules/iam"
}

module "ec2" {
  source = "./modules/ec2"

  depends_on = [
    module.iam
  ]
}
```

✔ Even if IAM role name is hardcoded
✔ Prevents race conditions

---

## 7️⃣ When You SHOULD Use `depends_on`

Use `depends_on` when:

✅ No direct variable/output reference exists
✅ One module relies on **side effects** of another
✅ Kubernetes / Helm / EKS addons
✅ IAM policies before services
✅ Networking before compute
✅ Avoid race conditions

---

## 8️⃣ When You SHOULD NOT Use `depends_on`

❌ When you already reference outputs
❌ Overusing it (anti-pattern)
❌ To pass values between modules
❌ For simple resources with implicit dependencies

---

## 9️⃣ Bad vs Good Example

### ❌ Bad (Unnecessary)

```hcl
module "ec2" {
  source    = "./modules/ec2"
  subnet_id = module.vpc.subnet_id

  depends_on = [module.vpc]
}
```

👉 Output reference already creates dependency

---

### ✅ Good (Required)

```hcl
module "helm" {
  source = "./modules/helm"

  depends_on = [
    module.eks
  ]
}
```

---

## 🔥 Interview One-Liner (Very Useful)

> “Terraform `depends_on` is used to enforce explicit dependencies when Terraform cannot automatically infer them, especially at the module level.”

---

## 10️⃣ Visual Flow (Mental Model)

```
VPC Module
    ↓
EKS Module
    ↓
Addons / Helm Module
    ↓
Applications
```

---

## 11️⃣ Best Practices Summary ✅

✔ Prefer implicit dependencies
✔ Use `depends_on` only when required
✔ Use it mostly with modules, not resources
✔ Keep dependency chain minimal
✔ Document why `depends_on` is used

---

## Prepared by:
## **Shaik Moulali**
