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
    * Choose the `New VM Instance` option
    * Name: `knewhub`
    * Region and zone: `northamerica-northeast1-b`
    * Machine configuration: `E2-medium`
    * VM provisioning model: `Standard`
    * Boot disk
        * Operating system version: `Ubuntu 20.04 LTS x86/64, amd focal image`
        * Boot disk type: `Balanced persistent disk`
        * Size: `10` GB
    * Service account: `compute-engine` service account created earlier
    * Firewall: `Allow HTTPS traffic`
    * Advanced options -> Networking -> Network interfaces -> Edit network interface: click on `default` network and select option `knewhub-vm` under "External IPv4 address"
* Point the domain `knewhub.com` to the static external IP address of the VM

## Create Cloud SQL database

* [Reference Guide: Create instances](https://cloud.google.com/sql/docs/postgres/create-instance)
* Create PostgreSQL instance
* Instance ID: `knewhub`
* Password: click on `Generate` button to generate a password
* Database version: `PostgreSQL 15`
* Cloud SQL edition: `Enterprise`
* Preset: `Development`
* Region: `northamerica-northeast1`
* Zonal availability: `Single zone`
* Configuration options -> Connections -> Authorized networks -> Add a network: enter the IPv4 address of the VM instance

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
    ssh-keygen -t rsa -f knewhub-vm-rails -C rails
    ```
    * Skip entering a passphrase by clicking `Enter` key
    * This creates two files: `knewhub-vm_rails` and `knewhub-vm-rails.pub`
    * Move the files to directory `~/.ssh` on the local machine if they are not already there
* Add the SSH public key to the VM
    * Navigate to the VM instances page on Google Cloud console
    * Edit instance
    * SSH keys: copy the content of the `knewhub-vm-rails.pub` file
* Ensure the VM is running then connect to it using this command. The `<VM_EXTERNAL_IP>` is the static external IP used in previous steps
    ```
    ssh -i ~/.ssh/knewhub-vm-rails rails@<VM_EXTERNAL_IP>
    ```
    * During the first connection, if the warning `The authenticity of host '<VM_EXTERNAL_IP>' can't be established` appears, enter `yes` to continue

### Installation of packages

* Once connected to the VM, run `sudo apt-get update` to update the list of packages
* The following packages need to be installed. Follow instructions from their respective documentation below
* Caddy
    * Used for the reverse proxy web server
    * https://caddyserver.com/docs/install#debian-ubuntu-raspbian
    * Edit the `Caddyfile` at `/etc/caddy/Caddyfile` to be:
        ```
        knewhub.com {
            reverse_proxy localhost:3000
        }
        ```
    * Check that the Caddy service is running with command `systemctl status caddy`. "Started Caddy." will appear on the logs
* Git
    * Used to install packages, and perform Git operations during deployment and within the Rails application
    * https://github.com/git-guides/install-git#debianubuntu
    * Check that Git was installed with command `git version`
* rbenv & ruby-build
    * Used to manage Ruby versions
    * https://github.com/rbenv/rbenv?tab=readme-ov-file#basic-git-checkout
        * Use the instructions for `bash`
        * Restart the shell with command `source ~/.bashrc`
        * Check that rbenv was installed with command `rbenv`. It should return a list of rbenv commands
    * https://github.com/rbenv/ruby-build?tab=readme-ov-file#clone-as-rbenv-plugin-using-git
* Ruby
    * Used to run our Rails application
    * Install dependencies
        * https://github.com/rbenv/ruby-build/wiki#ubuntudebianmint
    * Refer to the file `.ruby_version` for the version to install
    * Install Ruby with command `rbenv install <RUBY_VERSION>`
    * Apply this version globally with `rbenv global <RUBY_VERSION>``
    * Check that the correct Ruby version was installed with command `rbenv version`
* Redis
    * Used for storage by the Rails application
    * https://redis.io/docs/install/install-redis/install-redis-on-linux/
    * Check that Redis was installed with command `redis-server --version`
* Sidekiq
    * Used for background jobs by the Rails application
    * `gem install sidekiq`
    * `gem install bundler`
    * Check that Sidekiq was installed with command `sidekiq`. It should return logs with "Please point Sidekiq to a Rails application or a Ruby file to load your job classes with -r [DIR|FILE]."
* jq
    * Used to decrypt secrets from Secret Manager
    * `sudo apt-get install jq`
    * Check that jq was installed with command `jq`. It should return a list of jq commands

### Access secrets from Secret Manager

Environment variables are set by fetching secrets from Secret Manager. This is done by adding a script in the `.profile` file. This file is called every time the `rails` user logs in.

* Edit the `.profile` file at `~/.profile` to be:
    ```sh
    PROJECT_ID="knewhub"
    SECRETS=("RAILS_MASTER_KEY" "WEB_URL" "POSTGRES_HOST" "POSTGRES_DB" "POSTGRES_USER" "POSTGRES_PASSWORD" "GITHUB_APP_ID" "GITHUB_APP_SECRET" "BREVO_USERNAME" "BREVO_PASSWORD")

    function get_secret() {
        curl "https://secretmanager.googleapis.com/v1/projects/$PROJECT_ID/secrets/$1/versions/latest:access" \
        --request "GET" \
        --header "authorization: Bearer $(gcloud auth print-access-token)" \
        --header "content-type: application/json" \
        | jq -r ".payload.data" | base64 --decode
    }

    for secret in ${SECRETS[@]}; do
        export $secret=$(get_secret $secret)
    done
    ```
* Reload the file with command `. ~/.profile`
* Verify that environment variables are set with command `env`. It should return a list of environment variables and their values

### Load Rails application

### systemd services

systemd will be used to manage all services that the Rails application requires. The systemd services used are as follow.

* Caddy
    * The Caddy service was already set up as part of the package installation. No action is required
* redis-server
    * The redis-server service was already set up as part of the package installation. No action is required
* Sidekiq
    * Create a `sidekiq.service` file at `/etc/systemd/system/sidekiq.service` with the following:
        ```service
        [Unit]
        Description=sidekiq
        After=syslog.target network.target redis-server.service

        [Service]
        Type=notify
        NotifyAccess=all
        WatchdogSec=10
        WorkingDirectory=/home/rails/knewhub
        ExecStart=/bin/bash -lc 'exec /home/rails/.rbenv/shims/bundle exec sidekiq -e production'
        User=rails
        Group=rails
        UMask=0002
        Environment=MALLOC_ARENA_MAX=2
        RestartSec=1
        Restart=always
        StandardOutput=syslog
        StandardError=syslog
        SyslogIdentifier=sidekiq

        [Install]
        WantedBy=multi-user.target
        ```
* Knewhub (Rails application)
    * Create a `knewhub.service` file at `/etc/systemd/system/knewhub.service` with the following:
        ```service
        [Unit]
        Description=KnewHub
        After=network.target redis-server.service sidekiq.service
        
        [Service]
        Type=simple
        User=rails
        Group=rails
        WorkingDirectory=/home/rails/knewhub
        ExecStart=/bin/bash -lc 'exec /home/rails/.rbenv/shims/bundle exec rails server -e production'
        TimeoutSec=30
        RestartSec=15s
        Restart=always
        SyslogIdentifier=rails
        
        [Install]
        WantedBy=multi-user.target
        ```

Use command `systemctl list-units --type=service --state=running` to lists the systemd services that are currently running.

## Create additional storage disk attached to VM

## Deploy using Mina

## Display Systemd logs on Cloud Logging