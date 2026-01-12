Got it bro 😎 — you want a **super simple, single `main.tf` file** to provision a **GCP Compute Engine VM** without variables. Perfect for interviews.

Here’s a clean example:

---

```hcl
# Configure the GCP provider
provider "google" {
  project     = "my-gcp-project"                         # Replace with your GCP project ID
  region      = "us-central1"
  credentials = file("/home/user/gcp-service-account.json") # Replace with your JSON key path
}

# Create a Compute Engine VM
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}  # Assigns public IP
  }

  tags = ["terraform-vm"]
}

# Output instance info
output "instance_name" {
  value = google_compute_instance.vm_instance.name
}

output "instance_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
```

---

## ✅ Explanation (Interview Ready)

1. **Provider Block**: Connects Terraform to GCP using project, region, and service account credentials.
2. **`google_compute_instance` Resource**:

   * `name` = VM name
   * `machine_type` = type of instance (small, free-tier eligible)
   * `zone` = region zone
   * `boot_disk` = OS image (Debian 11)
   * `network_interface` = default network + public IP
3. **Outputs**:

   * `instance_name` → VM name
   * `instance_ip` → Public IP of the VM

---

### How to Run

```bash
terraform init
terraform plan
terraform apply
```

After `apply`, Terraform will create the VM and print the **instance name and IP**.

---
## Prepared by:
## **Shaik Moulali**

Do you want me to do that?
