# TruckCo Logistics – Azure Web Server Deployment

This repository contains Infrastructure as Code (IaC) and configuration management to deploy a Linux web server on Microsoft Azure using Terraform and Ansible, fully automated through GitHub Actions.

The project simulates the first infrastructure footprint for a Trucking Logistics application.

---


# Assignment Requirements Summary

This README explicitly covers the following required items:

### Prerequisites

* Terraform >= 1.5
* Ansible >= 2.10
* Azure CLI
* GitHub account with repository access
* Azure Subscription + Service Principal

### 2. Setup Steps

* Create Azure Service Principal for CI/CD authentication
* Store credentials as GitHub Secret (`AZURE_CREDENTIALS`)
* Configure Terraform remote backend in Azure Storage
* Configure GitHub Actions environment (`dev`)

### 3. Step‑by‑Step Deployment

* `terraform init`
* `terraform validate`
* `terraform plan`
* Manual approval
* `terraform apply`
* `ansible-playbook`

### 4. Design Decisions

Explained in the **Design Decisions** section below, including:

* Terraform + Ansible separation
* Remote Terraform state
* NSG with dynamic IP restriction
* GitHub Actions pipeline with approval

---

Infrastructure created:

* Azure Resource Group
* Virtual Network + Subnet
* Network Security Group (NSG)

  * Allow SSH (port 22) only from pipeline detected public IP
  * Allow HTTP (port 80) from anywhere
  * Deny all other inbound traffic
* Linux Virtual Machine with Public IP
* Remote Terraform State stored in Azure Storage Account
* Ansible configuration for server setup
* CI/CD pipeline with approval gate


# Prerequisites

Install locally (for manual execution):

* Terraform >= 1.5
* Ansible >= 2.10
* Azure CLI
* SSH client

Azure requirements:

* Azure Subscription
* Service Principal with Contributor role
* Storage Account for Terraform backend

---

# Azure Authentication Setup

Create Service Principal:

```
az ad sp create-for-rbac --name github-sp --role Contributor --scopes /subscriptions/<SUB_ID>
```

Save output as GitHub Secret:

```
AZURE_CREDENTIALS
```

Example JSON:

```
{
  "clientId": "xxxx",
  "clientSecret": "xxxx",
  "subscriptionId": "xxxx",
  "tenantId": "xxxx"
}
```

---

# Terraform Backend Setup

Create Storage Account manually:

```
az group create -n rg-tfstate -l eastus
az storage account create -n truckcostate -g rg-tfstate -l eastus --sku Standard_LRS
az storage container create -n tfstate --account-name truckcostate
```

Update backend.tf accordingly.

---

# Deployment via GitHub Actions

Pipeline stages:

1. Checkout code
2. Azure login
3. Detect runner public IP
4. Terraform Init
5. Terraform Validate
6. Terraform Plan
7. Manual Approval
8. Terraform Apply
9. Generate Ansible inventory
10. Run Ansible Playbook

Approval happens through workflow_dispatch button in GitHub UI.

---

# Manual Deployment Steps

## 1. Terraform Init

```
terraform -chdir=iac init
```

## 2. Terraform Plan

```
terraform -chdir=iac plan -var="my_ip=<YOUR_IP>/32"
```

## 3. Terraform Apply

```
terraform -chdir=iac apply
```

## 4. Run Ansible

```
ansible-playbook -i hosts.ini ansible/playbook.yml
```

---

# Ansible Configuration Tasks

The playbook performs:

* System update
* Disable root login
* Enforce key-based authentication
* Install and enable Nginx
* Deploy application stub page
* Configure UFW firewall (SSH + HTTP only)

Default webpage message:

```
Welcome to the TruckCo Logistics Portal. (Under Construction)
```

---

# SSH Strategy

Terraform generates SSH key pair automatically using TLS provider.

Public key → installed on VM
Private key → stored as GitHub Secret and used by Ansible

This avoids storing personal SSH keys in the repository.

---

# Design Decisions

## 1. Terraform + Ansible Separation

Terraform handles infrastructure provisioning.
Ansible handles server configuration.

This follows industry best practices for idempotent infrastructure.

## 2. Remote State in Azure Storage

Ensures safe collaboration and state locking.

## 3. NSG with Dynamic IP Detection

Pipeline automatically detects runner public IP to satisfy requirement:

Allow SSH only from local IP.

## 4. GitHub Actions Pipeline

Chosen for simplicity and integration with repository.
Includes manual approval stage for safe deployment.

## 5. Minimal VM Footprint

Ubuntu Linux VM chosen for:

* stability
* compatibility with Ansible
* low cost

---

# How to Access the Server

After deployment:

```
http://<public-ip>
```

You should see the TruckCo portal message.

---

# Troubleshooting

Common issues:

### Terraform cannot find SSH key

Use Terraform-generated key instead of ~/.ssh/id_rsa.pub

### NSG invalid IP

Ensure IP is passed as:

```
1.2.3.4/32
```

### Azure Login Failed

Verify AZURE_CREDENTIALS JSON format.

---

# Future Improvements

* Use Azure Key Vault for secrets
* Add SSL with Let's Encrypt
* Add AKS cluster for microservices
* Add monitoring with Azure Monitor
* Add Blue/Green deployment

---

# Author

Sandro Andrade
Cloud & DevOps Engineer