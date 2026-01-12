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

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform-EC2"
  }

  # Lifecycle block
  lifecycle {
    create_before_destroy = true      # Create new EC2 before destroying old one
    prevent_destroy       = false     # Can destroy (set true to protect)
    ignore_changes = [
      tags["Name"]                    # Ignore tag changes (won’t update EC2)
    ]
  }
}
```

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

