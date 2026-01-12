This is a **very important Terraform concept** — both for **real projects and interviews**.

---

# Terraform: `count` vs `for_each` – Clear Difference 🚀

## 1️⃣ What is `count`?

`count` creates **multiple instances of a resource/module** based on a **number**.

Got it bro 👍
I’ll keep it **very simple**, **clear**, **no complications**, and with **EC2 examples only**.

---

# EC2 Example: `count` vs `for_each` (Simple & Clear)

---

## 1️⃣ EC2 using `count` (Same EC2s)

### Use case

👉 You want **same type of EC2 instances**
👉 Example: 3 identical servers

### Code

```hcl
resource "aws_instance" "ec2" {
  count         = 3
  ami           = "ami-0abc123"
  instance_type = "t2.micro"

  tags = {
    Name = "count-ec2"
  }
}
```

### What Terraform creates

```
ec2[0]
ec2[1]
ec2[2]
```

### When to use `count`

✅ All EC2s are same
✅ Just need number of servers
❌ If you remove one → index problem

---
## What is for_each?

for_each creates resources based on a map or set of strings.
---
## 2️⃣ EC2 using `for_each` (we can create EC2 instances with different EC2-Instance types)

### Use case

👉 EC2 instances have **different names or roles**

### Code

```hcl
resource "aws_instance" "ec2" {
  for_each = {
    web = "t2.micro"
    app = "t2.small"
    db  = "t2.medium"
  }

  ami           = "ami-0abc123"
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
```

### What Terraform creates

```
ec2["web"]
ec2["app"]
ec2["db"]
```

### When to use `for_each`

✅ EC2s have **different purposes**
✅ Safe to delete one EC2
✅ Best for production

---

## 3️⃣ Very Simple Difference (One Line)

| Situation      | Use        |
| -------------- | ---------- |
| Same EC2s      | `count`    |
| Different EC2s | `for_each` |

---

## 4️⃣ What Happens If You Delete One?

### ❌ With `count`

```hcl
count = 3 → count = 2
```

Terraform may **recreate EC2s** ❌

### ✅ With `for_each`

```hcl
remove "app"
```

Only **app EC2** is deleted ✅

---

## 5️⃣ Interview Short Answer

> “I use `count` when EC2 instances are identical and `for_each` when instances have different names or roles.”

---

## 6️⃣ Final Rule (Remember This 🧠)

```
Same EC2 → count
Different EC2 → for_each
```

---
## Question:2
---
## how does it creates the instances at the same time will it create all instance or one by one?
Ah, this is a very good question bro 😎 – about **how Terraform creates multiple EC2 instances**. Let me explain clearly.

---

# How Terraform Creates Multiple Instances

When you use **`count`** or **`for_each`**, Terraform **does not literally create them all at the same microsecond**, but it **tries to create them in parallel whenever possible**.

---

## 1️⃣ Parallelism in Terraform

* Terraform uses a **dependency graph**.
* **Independent resources** are created in **parallel**.
* **Resources with dependencies** are created **one after another**.

---

### Example with `count`

```hcl
resource "aws_instance" "ec2" {
  count         = 3
  ami           = "ami-0abc123"
  instance_type = "t2.micro"
}
```

* Terraform sees **3 independent EC2 instances**.
* Terraform **sends 3 requests to AWS in parallel** (by default).
* **All 3 instances are created roughly at the same time**.

---

### Example with `for_each`

```hcl
resource "aws_instance" "ec2" {
  for_each      = {
    web = "t2.micro"
    app = "t2.small"
    db  = "t2.medium"
  }
  ami           = "ami-0abc123"
  instance_type = each.value
}
```

* Terraform sees **3 independent instances**.
* **Parallel creation** happens too, one per each key (`web`, `app`, `db`).

---

## 2️⃣ Controlling Parallelism

Terraform has a setting called **`-parallelism`**:

```bash
terraform apply -parallelism=5
```

* Default = 10
* Maximum number of resources Terraform will create **at the same time**.
* Example: `count = 20` but `-parallelism=5` → Terraform creates **5 at a time**, then next 5.

---

## 3️⃣ When Instances Are Created One by One

Terraform will **create sequentially** if:

* There are **dependencies**:

```hcl
resource "aws_instance" "ec2" {
  count         = 3
  ami           = "ami-0abc123"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet.id  # depends on subnet
}
```

* Or if you explicitly use **`depends_on`**

---

## 4️⃣ Visual Representation

```
Count = 3, No dependency → Parallel
  ┌─────┐  ┌─────┐  ┌─────┐
  │EC2 0│  │EC2 1│  │EC2 2│  ← created at the same time
  └─────┘  └─────┘  └─────┘

Count = 3, depends_on subnet → Sequential
  ┌─────────┐
  │Subnet   │  ← created first
  └─────────┘
  ┌─────┐  ┌─────┐  ┌─────┐
  │EC2 0│  │EC2 1│  │EC2 2│  ← parallel after subnet ready
  └─────┘  └─────┘  └─────┘
```

---

## 5️⃣ Key Points to Remember

1. Terraform **parallelizes independent resources**.
2. `count` or `for_each` → creates multiple resources **in parallel**.
3. Dependencies (`depends_on` or references) → sequential creation.
4. Use `-parallelism` to **control concurrency**.
5. Terraform **does not wait** for one EC2 to finish before starting the next, unless required.

---

💡 **Simple Rule:**

> “Terraform creates multiple EC2s **at the same time** unless there’s a dependency. Count/for_each = parallel creation by default.”

---
## Prepared by:
## **Shaik Moulali**


