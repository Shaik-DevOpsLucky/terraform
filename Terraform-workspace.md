# Terraform Workspaces – Simple Explanation 🚀

## 1️⃣ What is a Terraform Workspace?

> A **Terraform workspace** allows you to manage **multiple environments (dev, test, prod)** using the **same Terraform code** but **separate state files**.

📌 Same code
📌 Different state
📌 Same backend

---

## 2️⃣ Why Do We Need Workspaces?

Without workspaces:

* You need **separate folders** for dev, prod
* Duplicate Terraform code ❌

With workspaces:

* One codebase
* Multiple environments
* Each environment has its **own state file**

---

## 3️⃣ How Terraform Workspaces Work Internally 🧠

* Default workspace = `default`
* Each workspace has its **own `terraform.tfstate`**
* Terraform automatically picks the **state based on current workspace**

Example state paths (S3 backend):

```
env:/default/terraform.tfstate
env:/dev/terraform.tfstate
env:/prod/terraform.tfstate
```

---

## 4️⃣ Basic Workspace Commands

```bash
terraform workspace list        # list workspaces
terraform workspace new dev     # create new workspace
terraform workspace select dev  # switch workspace
terraform workspace show        # show current workspace
```

---

## 5️⃣ Simple AWS EC2 Example Using Workspaces

### main.tf

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = terraform.workspace == "prod" ? "t3.medium" : "t2.micro"

  tags = {
    Name = "ec2-${terraform.workspace}"
    Env  = terraform.workspace
  }
}
```

---

## 6️⃣ How It Works (Step-by-Step)

### Step 1: Default workspace

```bash
terraform apply
```

Creates:

```
EC2 → ec2-default
```

---

### Step 2: Create dev workspace

```bash
terraform workspace new dev
terraform apply
```

Creates:

```
EC2 → ec2-dev
```

---

### Step 3: Create prod workspace

```bash
terraform workspace new prod
terraform apply
```

Creates:

```
EC2 → ec2-prod (bigger instance)
```

✅ Same code
✅ Separate EC2s
✅ Separate state files

---

## 7️⃣ When to Use Terraform Workspaces

✅ Small to medium projects
✅ Dev / test / prod separation
✅ Same infra structure across environments
✅ Interview demos

---

## 8️⃣ When NOT to Use Workspaces

❌ Very large production systems
❌ Different infra per environment
❌ When strict isolation is required

👉 In big companies, **separate Terraform folders or repos** are often preferred for prod.

---

## 9️⃣ Interview One-Liner 💡

> “Terraform workspaces allow us to use the same Terraform configuration for multiple environments by maintaining separate state files per workspace.”

---

## 🔑 Final Simple Rule

```
Same code + Different environments = Terraform Workspaces
```

---
## Prepared by:
## *Shaik Moulali*
