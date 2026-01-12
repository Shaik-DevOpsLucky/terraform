# 1️⃣ Terraform Variables

**Variables in Terraform** are used to **make your configuration flexible and reusable**.
Instead of hardcoding values (like AMI ID, instance type, region), you **pass them as variables**.

---

### **Why use variables?**

* 🔹 **Reusable code** → same Terraform file can deploy in different regions or environments
* 🔹 **Avoid hardcoding** → safer and cleaner
* 🔹 **Parameterize environments** → dev, test, prod

---

### **Example – AWS EC2 with Variables**

#### variables.tf

```hcl
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  default     = "ami-0c55b159cbfafe1f0"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}
```

#### main.tf

```hcl
provider "aws" {
  region = var.region
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "Terraform-Variable-EC2"
  }
}
```

✅ **Now, changing region, AMI, or instance type is easy** without touching the main resource.

---

### **How to pass variables**

1. Using `terraform.tfvars` file:

```hcl
region        = "us-west-2"
instance_type = "t3.micro"
```

2. Using CLI:

```bash
terraform apply -var="region=us-west-2" -var="instance_type=t3.micro"
```

---

# 2️⃣ Terraform Provider Alias

**Provider alias** is used when you want **multiple providers of the same type** in one Terraform configuration.

---

### **Why use provider alias?**

* Deploy resources in **multiple regions**
* Use **different AWS accounts**
* Avoid creating **multiple Terraform configurations**

---

### **Example – AWS EC2 in Multiple Regions**

```hcl
provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us_west"
  region = "us-west-2"
}

resource "aws_instance" "east_instance" {
  provider      = aws.us_east
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = { Name = "EC2-East" }
}

resource "aws_instance" "west_instance" {
  provider      = aws.us_west
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = { Name = "EC2-West" }
}
```

✅ Deploy **same EC2 in 2 regions** in one Terraform config.

---

# 3️⃣ Quick Summary Table

| Feature        | Purpose / Use                                                        |
| -------------- | -------------------------------------------------------------------- |
| Variables      | Make code reusable, avoid hardcoding values, environment flexibility |
| Provider Alias | Use multiple providers of the same type (different regions/accounts) |

---

# 4️⃣ Interview One-Liners

* **Variables:** “Terraform variables allow dynamic configuration and make the code reusable across environments.”
* **Alias:** “Provider alias allows using multiple provider configurations in the same Terraform setup, for example multiple AWS regions.”

---

## Prepared by:
## **Shaik Moulali*
