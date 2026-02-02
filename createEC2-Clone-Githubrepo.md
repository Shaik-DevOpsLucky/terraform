# How to create an EC2 using Terraform and **auto-clone a GitHub repo** during instance launch.

---

## High-level flow

1. Terraform creates an **EC2 instance**
2. During EC2 boot, a **user_data script** runs
3. That script:

   * Installs git
   * Clones your GitHub repo into the EC2

---

## Option 1: Clone **public GitHub repo** (recommended for learning)

### 1️⃣ Terraform EC2 with `user_data`

```hcl
provider "aws" {
  region = "ap-south-1"   # change if needed
}

resource "aws_instance" "github_ec2" {
  ami           = "ami-0f5ee92e2d63afc18" # Amazon Linux 2 (check latest)
  instance_type = "t2.micro"
  key_name      = "my-key"               # your key pair name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install git -y

              cd /home/ec2-user
              git clone https://github.com/USERNAME/REPO_NAME.git

              chown -R ec2-user:ec2-user REPO_NAME
              EOF

  tags = {
    Name = "Terraform-GitHub-EC2"
  }
}
```

👉 Replace:

* `USERNAME`
* `REPO_NAME`
* `key_name`
* `AMI` (based on your region)

---

### 2️⃣ Deploy

```bash
terraform init
terraform plan
terraform apply
```

---

### 3️⃣ Verify on EC2

```bash
ssh -i my-key.pem ec2-user@<EC2_PUBLIC_IP>
ls
```

You’ll see:

```text
REPO_NAME
```

✅ Repo cloned automatically

---

## Option 2: Clone **private GitHub repo** (real-world setup)

### 🔐 Best practice: Use **GitHub token** (NOT username/password)

### Example `user_data` (token-based)

```hcl
user_data = <<-EOF
#!/bin/bash
yum install git -y

cd /home/ec2-user
git clone https://<GITHUB_TOKEN>@github.com/USERNAME/PRIVATE_REPO.git

chown -R ec2-user:ec2-user PRIVATE_REPO
EOF
```

⚠️ **Important**

* Token will be visible in Terraform state
* For production 👉 use **AWS Secrets Manager** or **SSM Parameter Store**

---

## Option 3 (BEST PRACTICE): Use **IAM + SSM + GitHub Deploy Key**

**Recommended for companies**:

* Create GitHub **deploy key**
* Store private key in EC2
* Clone using SSH

```bash
git clone git@github.com:USERNAME/REPO.git
```

If you want, I can give you:

* 🔐 Secure private repo cloning
* 🔄 Auto-pull on every reboot
* 🐳 Docker + Git clone
* ☸️ Clone repo + deploy to Kubernetes

---

# Prepared by:
*Shaik Moulali*
