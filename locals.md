# 🔷 What are `locals` in Terraform?

`locals` are **named values** that you define inside your Terraform configuration to:

* Avoid repeating the same values
* Improve readability
* Simplify complex expressions
* Make code cleaner and more maintainable

Think of `locals` like **temporary variables inside Terraform code**.

---

# 🧠 Simple Mental Model

If variables are:

> 📥 Inputs from outside

Then locals are:

> 🧮 Calculated values inside Terraform

---

# 🔎 Basic Syntax

```hcl
locals {
  name        = "moulali"
  environment = "dev"
}
```

You access them using:

```hcl
local.name
local.environment
```

---

# 🔷 Why Do We Use Locals?

Without locals:

```hcl
resource "aws_instance" "example1" {
  tags = {
    Name = "moulali-dev-server"
  }
}

resource "aws_s3_bucket" "example2" {
  tags = {
    Name = "moulali-dev-bucket"
  }
}
```

Now imagine you need to change `dev` → `prod` everywhere 😓

---

# ✅ Using Locals (Cleaner Version)

```hcl
locals {
  owner       = "moulali"
  environment = "dev"
}

resource "aws_instance" "example1" {
  tags = {
    Name = "${local.owner}-${local.environment}-server"
  }
}

resource "aws_s3_bucket" "example2" {
  tags = {
    Name = "${local.owner}-${local.environment}-bucket"
  }
}
```

Now change only in one place 👌

---

# 🔷 Real DevOps Example

```hcl
locals {
  project_name = "ecommerce"
  env          = "prod"
  common_tags = {
    Project     = "ecommerce"
    Environment = "prod"
    Owner       = "devops-team"
  }
}

resource "aws_instance" "app" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"

  tags = local.common_tags
}
```

✔ Reusable
✔ Clean
✔ Production-style

---

# 🔷 Locals vs Variables (Important Difference)

| Feature                    | variables       | locals               |
| -------------------------- | --------------- | -------------------- |
| Defined in                 | variables block | locals block         |
| Value provided by          | User / tfvars   | Defined inside code  |
| Can change per environment | Yes             | Not directly         |
| Used for                   | Inputs          | Calculations / reuse |
| CLI override possible      | Yes             | No                   |

---

# 🧠 Example Showing the Difference

### Variable (Input)

```hcl
variable "environment" {
  default = "dev"
}
```

Can override using:

```
terraform apply -var="environment=prod"
```

---

### Local (Internal Logic)

```hcl
locals {
  instance_name = "app-${var.environment}"
}
```

This is computed automatically.

---

# 🔷 Locals Can Use Expressions

Locals can contain:

* String interpolation
* Conditional logic
* Functions
* List manipulation
* Map merging

Example:

```hcl
locals {
  is_production = var.environment == "prod" ? true : false
}
```

---

# 🔷 Advanced Example – Conditional Instance Type

```hcl
variable "environment" {
  default = "dev"
}

locals {
  instance_type = var.environment == "prod" ? "t3.medium" : "t2.micro"
}

resource "aws_instance" "app" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = local.instance_type
}
```

✔ Automatically changes based on environment
✔ Clean logic separation

---

# 🔷 Important Rules About Locals

1️⃣ Defined once per module
2️⃣ Cannot be changed after definition
3️⃣ Evaluated during plan phase
4️⃣ Only accessible inside same module

---

# 🧠 When Should You Use Locals?

Use locals when:

✔ You are repeating values
✔ You want clean tagging strategy
✔ You need calculated values
✔ You want readable Terraform
✔ You need conditional logic

Do NOT use locals for:

❌ User input
❌ Environment-specific override
❌ Secret storage

---

# 🎯 Real-World DevOps Pattern

Production Terraform often looks like this:

```hcl
variable "environment" {}
variable "project_name" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```

Then all resources use:

```hcl
tags = local.common_tags
```

This is very common in enterprise infrastructure.

---

# 🧠 Interview-Level Answer

> Locals in Terraform are named values used to simplify configuration by storing reusable or computed expressions within a module. Unlike variables, locals are not external inputs but are internally calculated and help improve readability, maintainability, and reduce repetition.

---
