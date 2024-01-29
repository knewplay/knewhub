# Deployment instructions

## Overview

* Ruby on Rails application
* PostgreSQL database
* Sidekiq background worker
* Redis storage
* Caddy web server
* Deployed on a Linux VM on Google Cloud
* Additional storage disk attached to VM
* Automatic deployment using Mina
* Logs accessible on Google Cloud Logging

## Table of contents

* [Create virtual machine (VM) on Compute Engine](#create-virtual-machine-vm-on-compute-engine)
* [Create Cloud SQL database](#create-cloud-sql-database)
* [Store environment variables in Secret Manager](#store-environment-variables-in-secret-manager)

## Create virtual machine (VM) on Compute Engine

* Create service account
    * [Reference Guide: Create service accounts](https://cloud.google.com/iam/docs/service-accounts-create)
    * Service account ID: `compute-engine`
    * Role: `Cloud SQL Client`
* Reserve static external IP address
    * [Reference Guide: Reserve a static external IP address](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address)
    * Name: `knewhub-vm`
    * Network service tier: `Standard`
    * IP version: `IPv4`
    * Type: `regional` -> `northamerica-northeast1`
* Create VM
    * [Reference Guide: Create a VM that uses a user-managed service account](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances)
    * Name: `knewhub`
    * Region and zone: `northamerica-northeast1-b`
    * Machine configuration: `E2-medium`
    * VM provisioning model: `Standard`
    * Boot disk: `Ubuntu 20.04 LTS x86/64, amd focal image`
    * Service account: `compute-engine` service account created earlier
    * Firewall: `Allow HTTPS traffic`
    * Advanced options -> Networking -> Network interfaces: select IPv4 address created earlier

## Create Cloud SQL database

* [Reference Guide: Create instances](https://cloud.google.com/sql/docs/postgres/create-instance)
* Create PostgreSQL instance
* Instance ID: `knewhub`
* Password: click on `Generate` button to generate a password
* Database version: `PostgreSQL 15`
* Cloud SQL edition: `Enterprise`
* Region: `northamerica-northeast1`
* Configuration options -> Connections -> Authorized networks: enter static external IP address of the VM

## Store environment variables in Secret Manager

* [Reference Guide: Create and access a secret using Secret Manager](https://cloud.google.com/secret-manager/docs/create-secret-quickstart)
* Create secrets for the following environment variables
    * RAILS_MASTER_KEY
    * WEB_URL
    * POSTGRES_HOST
    * POSTGRES_DB
    * POSTGRES_USER
    * POSTGRES_PASSWORD
    * GITHUB_APP_ID
    * GITHUB_APP_SECRET
    * BREVO_USERNAME
    * BREVO_PASSWORD
* Configure Permissions for each secret
    * Grant access to the `compute-engine` service account with the roles `Secret Manager Secret Accessor` and `Secret Manager Viewer`
    * (This is done to prevent the service account from accessing other secrets that belong to the project. If this is not a concern, the service account's IAM permissions could be set at the project level instead)

## Configure VM

### Create `rails` user

* From a local terminal, generate the SSH keypair for a user named `rails`. This user will be used to perform all operations on the VM
    ```
    ssh-keygen -t rsa -f knewhub_vm_rails -C rails
    ```
    * This creates two files: `knewhub_vm_rails` and `knewhub_vm_rails.pub`
    * Move the files to folder `~/.ssh` on the local machine, if they are not already there
* Add the SSH public key to the VM
    * Navigate to the VM instances page on Google Cloud console
    * Edit instance
    * SSH keys: copy the content of the `knewhub_vm_rails.pub` file
* Connect to the VM with the command. The `<VM_EXTERNAL_IP>` is the static external IP used in previous steps
    ```
    ssh -i ~/.ssh/knewhub_vm_rails rails@<VM_EXTERNAL_IP>
    ```

### Installations
### Access secrets from Secret Manager
### Load Rails application
### Systemd services


## Create additional storage disk attached to VM

## Deploy using Mina

## Display Systemd logs on Cloud Logging