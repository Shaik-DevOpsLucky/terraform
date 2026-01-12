## Questions:
## 1).I have provisioned the aws resources using terraform the infra is in place but someone from my team has modified the infra manually (instance type from t2.large to m5.xlarge) from console how can i identify and ensure the state file is upto date?

This is a **classic Terraform drift scenario** 👍
Let’s break it down **clearly, step-by-step**, and then I’ll give you **best practices to prevent this in future**.

---

## What happened (Problem)

* Infrastructure was **provisioned using Terraform**
* Someone **manually modified the resource from AWS Console**

  * Example: `t2.large → m5.xlarge`
* Terraform **state file still thinks** the instance is `t2.large`
* This causes **state drift**

---

## How to IDENTIFY the drift 🔍

### ✅ 1. Run `terraform plan` (Most important)

```bash
terraform plan
```

Terraform will:

* Compare **Terraform state**
* With **actual AWS infrastructure**
* Show you **exactly what changed**

You’ll see something like:

```diff
~ instance_type = "t2.large" -> "m5.xlarge"
```

➡️ This confirms **manual modification**

---

### ✅ 2. Refresh state without applying changes

If you only want to **update state from real infra**:

```bash
terraform refresh
```

⚠️ Note:

* This **updates the state file**
* **Does NOT change AWS resources**
* Useful only if you want Terraform to **accept manual change**

---

### ✅ 3. Use targeted refresh (Terraform v1.5+)

Better and safer:

```bash
terraform plan -refresh-only
```

or

```bash
terraform apply -refresh-only
```

✔ Reads real infra
✔ Updates state
✔ No infrastructure changes

---

### ✅ 4. Compare directly (optional deep check)

```bash
terraform show
```

Then compare with:

```bash
aws ec2 describe-instances --instance-ids <id>
```

---

## How to ENSURE state file is up to date 🧠

You have **two valid approaches** — choose based on intent.

---

### 🔹 Option 1: Accept the manual change (Update state only)

If `m5.xlarge` is correct and should remain:

```bash
terraform apply -refresh-only
```

✔ State updated
✔ Infra unchanged
✔ Terraform now matches reality

---

### 🔹 Option 2: Enforce Terraform as source of truth (Recommended)

If the change was **not approved**:

1. Keep `instance_type = "t2.large"` in `.tf`
2. Run:

```bash
terraform apply
```

Terraform will:

* Revert EC2 back to `t2.large`
* Enforce IaC discipline

---

## Best Practices to PREVENT this 🚫 (Very Important)

### 🔐 1. Restrict console access

* Use **IAM policies**
* Deny `ec2:ModifyInstanceAttribute`
* Allow changes **only via CI/CD role**

---

### 🔐 2. Enable Terraform state locking

If using S3 backend:

```hcl
backend "s3" {
  bucket         = "terraform-state-bucket"
  key            = "prod/infra.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-locks"
}
```

✔ Prevents parallel changes
✔ Avoids state corruption

---

### 📊 3. Enable Drift Detection (Highly recommended)

Use:

* `terraform plan` in CI daily
* AWS Config rules
* Terraform Cloud drift detection

Example CI check:

```bash
terraform plan -detailed-exitcode
```

Exit codes:

* `0` → No drift
* `2` → Drift detected 🚨

---

### 📜 4. Audit who changed it

Use **CloudTrail**

* Filter:

```text
Event name: ModifyInstanceAttribute
```

* Identify **who changed instance type**

---

## Summary (TL;DR)

| Task                 | Command                         |
| -------------------- | ------------------------------- |
| Identify drift       | `terraform plan`                |
| Sync state only      | `terraform apply -refresh-only` |
| Revert infra         | `terraform apply`               |
| Prevent future drift | IAM + CI + State locking        |

---
---
## Q2:

## 2).If i run this command what happen will it update m5.xlarge or t2.large instate file?
---
Good question — this is exactly where people get confused 👍
Let’s be **very precise**.

You are asking about this command:

```bash
terraform plan -refresh-only
```

(or `terraform apply -refresh-only`)

---

## What Terraform will do (100% clearly)

### ✅ It will update the **state file** to match **what exists in AWS**

**NOT** what is written in your `.tf` files.

So if:

* AWS Console shows → **`m5.xlarge`**
* Terraform code still has → **`t2.large`**

### 👉 After `-refresh-only`

The **state file will be updated to `m5.xlarge`**

✔ Terraform accepts the manual change
✔ No infrastructure changes
❌ Your `.tf` code is NOT modified

---

## What it will NOT do ❌

* ❌ It will NOT change the EC2 instance back to `t2.large`
* ❌ It will NOT apply Terraform code
* ❌ It will NOT modify AWS resources

It only **reads AWS → updates state**

---

## Simple truth table 🧠

| AWS actual | .tf code | State after `-refresh-only` |
| ---------- | -------- | --------------------------- |
| m5.xlarge  | t2.large | **m5.xlarge**               |
| t2.large   | t2.large | t2.large                    |
| m5.large   | t3.large | **m5.large**                |

State **always follows AWS** with refresh-only.

---

## When to use `-refresh-only`

Use it **only if**:

* Manual change is **approved**
* You want Terraform to **accept reality**

```bash
terraform apply -refresh-only
```

---

## When NOT to use it 🚫

Do **NOT** use `-refresh-only` if:

* Manual changes are accidental
* Terraform must be the source of truth

Instead:

```bash
terraform apply
```

This will:

* Revert EC2 back to `t2.large`
* Keep state aligned with code

---

## One-liner summary 🔥

> `-refresh-only` updates **state to m5.xlarge**,
> `terraform apply` enforces **t2.large**.

---

## Prepared by
## **Shaik Moulali**

