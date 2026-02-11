# 🔷 What Are Terraform Provisioners?

Provisioners are special blocks inside a Terraform resource that allow you to execute commands or copy files:

* On the **local machine** (where Terraform runs)
* On the **remote machine** (like EC2, VM, etc.)

They run:

* After a resource is created (default)
* Before a resource is destroyed (if `when = destroy` is used)

---

# 🎯 Why Do We Need Provisioners?

## 📘 Step 1: Understand Terraform’s Role

Terraform is a **Declarative Infrastructure as Code tool**.

It is designed to:

* Create infrastructure (EC2, VPC, Subnet, Security Groups)
* Update infrastructure
* Destroy infrastructure
* Maintain infrastructure state

Terraform works like this:

```
Desired State (your .tf files)
        ↓
Compare with real cloud
        ↓
Make them match
```

This is declarative behavior.

---

## 📘 Step 2: What Terraform Does NOT Do

Terraform can create:

* EC2 instance
* VPC
* Load Balancer
* RDS
* IAM roles

But Terraform does NOT automatically:

* Install Nginx inside EC2
* Configure Apache
* Deploy application code
* Modify Linux configuration files
* Restart system services

Why?

Because Terraform manages **infrastructure**, not **OS-level configuration**.

---

# 🧠 Mental Model (Very Important)

Think like this:

Terraform = Builds the house
Provisioner = Goes inside and arranges furniture

But ideally…

You should build the house with furniture already inside (using AMI, Packer, user_data).

Provisioners are like:

Manually entering the house after it is built.

---

# ⚠️ Why Provisioners Are Considered “Last Resort”

Provisioners break Terraform’s pure declarative model.

Terraform tracks infrastructure state.

But provisioners:

* Do not track file changes
* Do not track installed packages
* Are not idempotent
* Depend on SSH connectivity
* Can fail partially
* May leave server in inconsistent state

That’s why HashiCorp recommends using:

* user_data
* Cloud-init
* Packer (immutable AMIs)
* Ansible / Chef / Puppet

Provisioners should be used only when no better alternative exists.

---
<img width="1400" height="810" alt="image" src="https://github.com/user-attachments/assets/8366f1dd-9d76-40d6-b2df-36f8b0fd41ac" />


# 🔹 Types of Terraform Provisioners

There are 3 types:

1. local-exec
2. remote-exec
3. file

Now let’s deeply understand each one.

---

# 🟢 1️⃣ local-exec Provisioner

---

## 📘 What Is local-exec?

`local-exec` executes a command on:

> 🖥️ The machine where Terraform is running.

It does NOT connect to the created resource.

It runs:

* After resource creation
* Or during destroy (if configured)

---

## 🧠 Internal Flow

```
terraform apply
↓
Resource is created
↓
local-exec runs on YOUR laptop/server
```

---

## 🎯 Why Use local-exec?

Used when you need to:

* Call AWS CLI
* Trigger external scripts
* Send notifications
* Update DNS
* Generate local files
* Integrate CI/CD tools

---

## 🧪 Basic Example

```hcl
resource "null_resource" "example" {
  provisioner "local-exec" {
    command = "echo Terraform executed successfully > output.txt"
  }
}
```

What happens?

* Terraform creates null_resource
* Then runs command
* output.txt created on your local machine

No remote server involved.

---

## 🧪 Practical Example (With EC2)

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo EC2 Created with IP ${self.public_ip}"
  }
}
```

What happens?

* EC2 is created
* Terraform fetches public IP
* Writes IP into local file

This is useful for:

* Creating Ansible inventory
* Passing IP to monitoring tools

---

## 🧠 Advanced Example – Re-run When Script Changes

```hcl
resource "null_resource" "deploy" {
  triggers = {
    script_hash = filesha256("deploy.sh")
  }

  provisioner "local-exec" {
    command = "bash deploy.sh"
  }
}
```

If deploy.sh changes:

* Hash changes
* null_resource recreates
* Provisioner runs again

This makes execution conditional.

---

# 🟡 2️⃣ remote-exec Provisioner

---

## 📘 What Is remote-exec?

`remote-exec` runs commands:

👉 Inside the created remote server (like EC2)

It requires:

* SSH access (Linux)
* WinRM (Windows)
* connection block

---

## 🧠 Internal Flow

```
terraform apply
↓
EC2 created
↓
Terraform waits for SSH
↓
Connects to server
↓
Runs commands
```

If SSH fails → Provisioner fails.

---

## 🧪 Basic Example – Create File Inside Server

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name      = "mykey"

  provisioner "remote-exec" {
    inline = [
      "touch hello.txt"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("mykey.pem")
    host        = self.public_ip
  }
}
```

This:

* Creates EC2
* SSH into EC2
* Creates hello.txt inside EC2

---

## 🧪 Real Example – Install Nginx

```hcl
provisioner "remote-exec" {
  inline = [
    "sudo yum update -y",
    "sudo yum install nginx -y",
    "sudo systemctl start nginx"
  ]
}
```

Now your server becomes a web server.

---

## 🧠 Advanced Option – on_failure

```hcl
provisioner "remote-exec" {
  on_failure = continue

  inline = [
    "sudo systemctl restart myapp"
  ]
}
```

Options:

* fail (default)
* continue

Used when step is optional.

---

## ⚠️ Why remote-exec Is Risky

* SSH may not be ready
* Security group may block port 22
* Wrong key
* Network issue
* Not idempotent

Better alternative:

Use user_data.

---

# 🔵 3️⃣ file Provisioner

---

## 📘 What Is file Provisioner?

It copies files:

Local machine → Remote server

It does NOT execute files.

Requires connection block.

---

## 🧠 Internal Flow

```
EC2 created
↓
SSH connection
↓
File transferred
```

---

## 🧪 Basic Example

```hcl
provisioner "file" {
  source      = "app.conf"
  destination = "/home/ec2-user/app.conf"
}
```

This copies the file only.

---

## 🧪 Directory Copy Example

```hcl
provisioner "file" {
  source      = "app/"
  destination = "/home/ec2-user/app/"
}
```

Copies entire folder.

---

# 🧠 Real-World Pattern (File + Remote-Exec Together)

Most common pattern:

1. Copy script
2. Make executable
3. Run it

```hcl
resource "aws_instance" "app" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name      = "mykey"

  provisioner "file" {
    source      = "install.sh"
    destination = "/home/ec2-user/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x install.sh",
      "./install.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("mykey.pem")
    host        = self.public_ip
  }
}
```

---

# 🔴 Additional Important Concepts

## 1️⃣ when = destroy

Runs before resource deletion.

```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo Resource is being destroyed"
}
```

Use cases:

* Backup data
* Deregister server
* Cleanup monitoring

---

## 2️⃣ null_resource

Used when you need provisioner without real infrastructure.
It does not create any resources.

```hcl
resource "null_resource" "runner" {
  provisioner "local-exec" {
    command = "echo Running script"
  }
}
```

---

## 3️⃣ Multiple Provisioners

They execute in the order written.

---

# 🚀 Production Best Practices

Instead of heavy provisioners:

| Scenario                 | Recommended    |
| ------------------------ | -------------- |
| Install packages         | user_data      |
| App deployment           | CI/CD pipeline |
| Configuration management | Ansible        |
| Immutable infra          | Packer         |
| Complex setup            | Cloud-init     |

---

# 🧠 Interview-Level Summary

Provisioners allow execution of local or remote commands during resource lifecycle events. They are useful for post-provisioning configuration but are discouraged in production due to lack of idempotency and reliability concerns.

---

# 🔁 Difference Between Provisioners and user_data

Understanding the difference between **Provisioners** and **user_data** is very important in Terraform, especially for production-grade infrastructure design.

---

## 🔷 What is `user_data`?

`user_data` is a script that runs automatically when an EC2 instance boots for the first time.

It is executed by:

* **cloud-init (Linux)**
* EC2 launch mechanism

It runs **during the instance boot process**, not after Terraform finishes.

---

### 🧠 Execution Flow of user_data

```
Terraform creates EC2
        ↓
Instance starts booting
        ↓
cloud-init reads user_data
        ↓
Script executes automatically
```

---

### ✅ Example: Install Nginx using user_data

```hcl
resource "aws_instance" "web_userdata" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install nginx -y
              systemctl start nginx
              EOF
}
```

✔ No SSH required
✔ No connection block
✔ Production-friendly
✔ More reliable

---

## 🔷 What are Provisioners?

Provisioners execute commands **after a resource is created** (or before it is destroyed).

They are used for:

* Running remote commands (remote-exec)
* Running local commands (local-exec)
* Copying files (file)

Provisioners depend on SSH (for remote-exec and file).

---

### 🧠 Execution Flow of Provisioner

```
Terraform creates EC2
        ↓
Instance becomes reachable
        ↓
Terraform connects via SSH
        ↓
Commands are executed
```

---

### ⚠️ Example: Install Nginx using Provisioner

```hcl
resource "aws_instance" "web_provisioner" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name      = "mykey"

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo systemctl start nginx"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("mykey.pem")
    host        = self.public_ip
  }
}
```

❌ Requires SSH access
❌ Requires open port 22
❌ Can fail if instance is not ready
❌ Considered last resort

---

# 🔍 Side-by-Side Comparison

| Feature                 | user_data       | Provisioners        |
| ----------------------- | --------------- | ------------------- |
| Execution Time          | During boot     | After creation      |
| Requires SSH            | ❌ No            | ✅ Yes (remote-exec) |
| Uses cloud-init         | ✅ Yes           | ❌ No                |
| Reliability             | More stable     | Less stable         |
| Idempotent              | More controlled | Not guaranteed      |
| Production Recommended  | ✅ Yes           | ⚠️ Last resort      |
| Works with Auto Scaling | ✅ Yes           | ❌ Risky             |

---

# 🚨 Why HashiCorp Recommends Avoiding Provisioners

Provisioners:

* Break Terraform’s declarative model
* Are not idempotent
* Depend on SSH connectivity
* Can fail due to network/timeouts
* Make infrastructure less predictable

Instead, HashiCorp recommends:

* ✅ `user_data`
* ✅ Cloud-init
* ✅ Packer (Immutable AMIs)
* ✅ Ansible / Chef for configuration management

---

# 🎯 Production Best Practice

If you need to install software:

👉 Prefer `user_data`

If you need complex configuration:

👉 Use configuration management tools

If you need immutable infrastructure:

👉 Use Packer to bake AMIs

Use provisioners only when no other option exists.

---

# 🧠 Interview-Level Summary

> user_data runs during instance boot using cloud-init and does not require SSH, making it more reliable and production-ready.
> Provisioners run after resource creation, depend on SSH connectivity, and are considered a last resort due to reliability and idempotency concerns.

---

# 🎯 Final Understanding

Provisioners are:

✔ Useful for small automation
✔ Good for quick setup
✔ Helpful in learning environments

But in production:

🚫 Avoid heavy usage
🚫 Prefer immutable infrastructure

---

## Prepared by:
*Shaik Moulali*
