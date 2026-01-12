### Terraform Modules – Clear & Practical Explanation 🚀

**Terraform modules** are reusable, configurable blocks of Terraform code. They help you **avoid repetition**, **standardize infrastructure**, and **manage complex setups** cleanly.

---

## 1️⃣ Why Terraform Modules?

Without modules → duplicate code
With modules → reusable, clean, scalable infra

### Benefits

* ♻️ Reusability
* 🧹 Clean & organized code
* 🔐 Standardization
* 📈 Easy scaling
* 👥 Team collaboration

---

## 2️⃣ Types of Terraform Modules

### 1. **Root Module**

* The main folder where you run:

```bash
terraform init
terraform plan
terraform apply
```

### 2. **Child Module**

* A reusable module called by the root module

📁 Example structure:

```
terraform-project/
│── main.tf
│── variables.tf
│── outputs.tf
│
└── modules/
    └── ec2/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 3️⃣ Creating a Simple EC2 Module

### 📦 modules/ec2/main.tf

```hcl
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = var.instance_name
  }
}
```

### 📦 modules/ec2/variables.tf

```hcl
variable "ami_id" {}
variable "instance_type" {}
variable "instance_name" {}
```

### 📦 modules/ec2/outputs.tf

```hcl
output "instance_id" {
  value = aws_instance.this.id
}
```

---

## 4️⃣ Calling the Module (Root Module)

### 📄 main.tf

```hcl
module "ec2_instance" {
  source         = "./modules/ec2"
  ami_id         = "ami-0abc123"
  instance_type  = "t2.micro"
  instance_name  = "terraform-ec2"
}
```

---

## 5️⃣ Passing Variables & Outputs

### Access output from module:

```hcl
module.ec2_instance.instance_id
```

---

## 6️⃣ Module Source Types

```hcl
source = "./modules/ec2"                 # Local
source = "git::https://github.com/org/repo.git"
source = "terraform-aws-modules/vpc/aws" # Terraform Registry
```

---

## 7️⃣ Best Practices (Important for Interviews & Real Projects)

✅ One resource type per module
✅ Use meaningful variable names
✅ Add default values where possible
✅ Use `versions.tf`
✅ Avoid hardcoding values
✅ Keep modules small & focused
✅ Use outputs only when required

---

## 8️⃣ Real-World Example (AWS Infra)

* VPC module
* Subnet module
* Security Group module
* EKS / EC2 / RDS modules
* IAM module

Root module **orchestrates**, child modules **build infra**

---

## 9️⃣ Interview One-Liner 💡

> “Terraform modules are reusable, parameterized infrastructure components that help standardize, scale, and manage cloud resources efficiently.”

---
## Prepared by:
## **Shaik Moulali**
