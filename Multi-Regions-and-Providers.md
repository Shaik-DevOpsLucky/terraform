# Terraform: Basics, Multi-Region, and Multi-Provider Configuration

This document explains **Terraform basics**, and clearly demonstrates **Multi-Region and Multi-Provider setups**. It is designed for **learning, interviews, and real-world DevOps projects**.

---

## 📌 1. Terraform Basics

* **Terraform** is an open-source infrastructure as code (IaC) tool.
* Enables provisioning of **cloud infrastructure** across multiple providers.
* Uses **HCL (HashiCorp Configuration Language)** for configuration files.
* Key concepts:

  * **Provider**: Cloud or service you want to manage (AWS, Azure, GCP).
  * **Resource**: Infrastructure component (EC2, VM, Storage Bucket).
  * **Module**: Reusable Terraform configuration.
  * **State**: Stores current infra snapshot.
  * **Variables/Outputs**: For dynamic configuration and exposing values.

---

## 📌 2. Key Concepts for Multi-Region and Multi-Provider

### 🔹 Multi-Region

* Same **cloud provider** (example: AWS)
* Resources deployed in **multiple regions** (ap-south-1, us-east-1, etc.)
* Mainly used for **Disaster Recovery (DR)** and **High Availability**
* **Provider alias is required** to differentiate regions

### 🔹 Multi-Provider

* Using **multiple cloud providers together**
* Example: **AWS + Azure + GCP**
* Used for **hybrid cloud**, **vendor independence**, and **enterprise architectures**
* **Provider alias is NOT needed**

---

## 🏗️ 3. Architecture Overview

```
Terraform
 ├── AWS (ap-south-1)
 │    └── EC2 / RDS
 ├── AWS (us-east-1)
 │    └── EC2 / DR
 ├── Azure
 │    └── Resource Group / VM
 └── GCP
      └── Storage / VM
```

---

## 📂 4. Project Structure

```
terraform-demo/
│── provider.tf
│── aws-multi-region.tf
│── multi-provider.tf
│── variables.tf
│── outputs.tf
```

---

# 🌍 5. MULTI-REGION CONFIGURATION (AWS)

## 5.1 Provider Configuration with Alias

```hcl
provider "aws" {
  region = "ap-south-1"  # Primary Region (Mumbai)
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"   # Secondary / DR Region
}
```

---

## 5.2 Resources in Primary Region

```hcl
resource "aws_instance" "primary_ec2" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t2.micro"

  tags = {
    Name = "Primary-Mumbai-EC2"
  }
}
```

---

## 5.3 Resources in Secondary Region (Using Alias)

```hcl
resource "aws_instance" "dr_ec2" {
  provider      = aws.us
  ami           = "ami-yyyyyyyy"
  instance_type = "t2.micro"

  tags = {
    Name = "DR-US-EC2"
  }
}
```

---

## ✅ Multi-Region Best Practices

* Always use **provider aliases**
* Keep DR region lightweight
* Use Route53 for failover
* Separate state files for prod & DR if needed

---

# ☁️ 6. MULTI-PROVIDER CONFIGURATION (AWS + Azure + GCP)

## 6.1 Providers Configuration

```hcl
provider "aws" {
  region = "ap-south-1"
}

provider "azurerm" {
  features {}
}

provider "google" {
  project = "my-gcp-project"
  region  = "us-central1"
}
```

---

## 6.2 AWS Resource Example

```hcl
resource "aws_s3_bucket" "aws_bucket" {
  bucket = "terraform-aws-bucket-demo"
}
```

---

## 6.3 Azure Resource Example

```hcl
resource "azurerm_resource_group" "azure_rg" {
  name     = "azure-demo-rg"
  location = "East US"
}
```

---

## 6.4 GCP Resource Example

```hcl
resource "google_storage_bucket" "gcp_bucket" {
  name     = "terraform-gcp-bucket-demo"
  location = "US"
}
```

---

## ✅ Multi-Provider Best Practices

* Separate credentials for each cloud
* Use environment variables or secret managers
* Avoid tight coupling between providers
* Separate state files if complexity grows

---

# 🧠 7. Interview Comparison

| Feature         | Multi-Region           | Multi-Provider          |
| --------------- | ---------------------- | ----------------------- |
| Cloud Providers | One (AWS only)         | AWS + Azure + GCP       |
| Regions         | Multiple               | Independent             |
| Main Goal       | DR & HA                | Hybrid / Vendor freedom |
| Example         | ap-south-1 + us-east-1 | AWS + Azure + GCP       |

---

# 🚀 8. Use Cases

### Multi-Region:

* Primary in Mumbai, DR in US-East
* Low latency for global users
* RDS replication across regions

### Multi-Provider:

* Hybrid cloud deployment (AWS + Azure + GCP)
* Avoid vendor lock-in
* Use best-of-breed services per cloud
* Enterprise migration / multi-cloud strategy

---

## 📌 9. Summary

* **Basics:** Terraform uses providers, resources, modules, state, variables, outputs.
* **Multi-Region:** One provider, multiple regions, **requires aliases**.
* **Multi-Provider:** Different providers (AWS, Azure, GCP), **no alias needed**.
* Terraform handles both cleanly using providers and aliases where required.

---

# Prepared by:
*Shaik Moulali*
