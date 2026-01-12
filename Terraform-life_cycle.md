# Terraform Lifecycle – Simple Explanation ✅

**Terraform lifecycle** controls **how Terraform handles resources** during **create, update, and delete**.

Think of it as **rules for managing the resource lifecycle**.

---

## 4️⃣ Lifecycle Arguments

The main lifecycle arguments:

| Argument                | Purpose                                                              |
| ----------------------- | -------------------------------------------------------------------- |
| `create_before_destroy` | Create new resource **before deleting old one** (prevents downtime)  |
| `prevent_destroy`       | Prevent Terraform from **destroying the resource** accidentally      |
| `ignore_changes`        | Ignore changes to specified attributes (Terraform won’t update them) |

---

## 2️⃣ AWS EC2 Example with Lifecycle

Here’s a **simple EC2 example** using lifecycle:

# 1️⃣ `prevent_destroy` Example

> **Purpose:** Prevent Terraform from accidentally destroying a critical resource.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "critical_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  instance_type = "t2.micro"

  tags = {
    Name = "Critical-EC2"
  }

  lifecycle {
    prevent_destroy = true
  }
}
```

### How it works:

* If you run `terraform destroy`, Terraform **will fail** for this resource.
* Protects production servers from accidental deletion ✅

---

# 2️⃣ `ignore_changes` Example

> **Purpose:** Ignore updates to specific attributes that may change outside Terraform (like tags).

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ignore_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "Ignore-EC2"
    Env  = "Dev"
  }

  lifecycle {
    ignore_changes = [
      tags["Env"]   # Terraform will ignore any manual changes to this tag
    ]
  }
}
```

### How it works:

* If someone changes `Env` tag in AWS console, Terraform **won’t try to revert it**.
* Useful for attributes managed manually or by other tools ✅

---

# 3️⃣ `create_before_destroy` Example

> **Purpose:** Avoid downtime by creating a new resource before deleting the old one.

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "before_destroy_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "BeforeDestroy-EC2"
  }

  lifecycle {
    create_before_destroy = true
  }
}
```

### How it works:

* If you change `instance_type` from `t2.micro` → `t2.small`
* Terraform will **create the new EC2 first**, then **destroy the old EC2**
* No downtime for critical resources ✅

---

## 🔹 Quick Summary

| Lifecycle Argument      | Effect                                                          |
| ----------------------- | --------------------------------------------------------------- |
| `prevent_destroy`       | Protect resource from accidental deletion                       |
| `ignore_changes`        | Ignore changes to attributes that are managed outside Terraform |
| `create_before_destroy` | Create new resource before deleting old one to avoid downtime   |

---
## 3️⃣ How It Works

1. `create_before_destroy = true`

   * If you change `instance_type` from `t2.micro` → `t2.small`
   * Terraform **creates new EC2 first**, then deletes old EC2
   * Prevents downtime ✅

2. `prevent_destroy = true`

   * Prevents accidental deletion
   * Example: `terraform destroy` will **fail** for this EC2

3. `ignore_changes`

   * Terraform **ignores changes** to specific attributes
   * Useful for attributes that are managed outside Terraform (tags, user data, etc.)

---

## 4️⃣ Why Use Lifecycle

* Avoid downtime for critical resources (`create_before_destroy`)
* Protect production servers (`prevent_destroy`)
* Ignore changes that don’t need Terraform to manage (`ignore_changes`)

---

## 5️⃣ Quick Interview Line

> “Terraform lifecycle allows us to control how resources are created, updated, or destroyed, ensuring safe updates, preventing accidental deletion, and ignoring attributes managed externally.”

---

## Prepared by:
## **Shaik Moulali**

