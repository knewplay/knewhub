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
* [Configure VM](#configure-vm)
    + [Create `rails` user](#create-rails-user)
    + [Installation of packages](#installation-of-packages)
    + [Access secrets from Secret Manager](#access-secrets-from-secret-manager)
    + [Set up SSH for GitHub](#set-up-ssh-for-github)
    + [Start Rails application](#start-rails-application)
    + [systemd services](#systemd-services)
        - [Useful commands](#useful-commands)
* [Create additional storage disk attached to VM](#create-additional-storage-disk-attached-to-vm)
    + [Create and attach disk](#create-and-attach-disk)
    + [Format and mount disk](#format-and-mount-disk)
    + [Persist mount after restart with fstab](#persist-mount-after-restart-with-fstab)
* [Deploy using Mina](#deploy-using-mina)
    + [Add Mina script](#add-mina-script)
    + [Remove existing `knewhub` directory](#remove-existing-knewhub-directory)
    + [Modify systemd services and fstab to work with Mina releases](#modify-systemd-services-and-fstab-to-work-with-mina-releases)
* [Display systemd logs on Cloud Logging](#display-systemd-logs-on-cloud-logging)
    + [Active Ops Agent](#active-ops-agent)
    + [View logs in Cloud Logging](#view-logs-in-cloud-logging)
    + [Modify logger for Rails](#modify-logger-for-rails)
    + [Modify logger for Sidekiq](#modify-logger-for-sidekiq)
    + [Enable custom formatter for Ops Agent](#enable-custom-formatter-for-ops-agent)

## Create virtual machine (VM) on Compute Engine

1. Create service account
    * [Reference Guide: Create service accounts](https://cloud.google.com/iam/docs/service-accounts-create)
    * Service account ID: `compute-engine`
    * Role: `Cloud SQL Client`
2. Reserve static external IP address
    * [Reference Guide: Reserve a static external IP address](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address)
    * Name: `knewhub-vm`
    * Network service tier: `Standard`
    * IP version: `IPv4`
    * Type: `regional` -> `northamerica-northeast1`
3. Create VM
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
4. Point the domain `knewhub.com` to the static external IP address of the VM

## Create Cloud SQL database


[Reference Guide: Create instances](https://cloud.google.com/sql/docs/postgres/create-instance)
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

[Reference Guide: Create and access a secret using Secret Manager](https://cloud.google.com/secret-manager/docs/create-secret-quickstart)

1. Create secrets for the following environment variables
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
2. Configure Permissions for each secret
    * Grant access to the `compute-engine` service account with the roles `Secret Manager Secret Accessor` and `Secret Manager Viewer`
    * (This is done to prevent the service account from accessing other secrets that belong to the project. If this is not a concern, the service account's IAM permissions could be set at the project level instead)

## Configure VM

### Create `rails` user

1. From a local terminal, generate the SSH keypair for a user named `rails`. This user will be used to perform all operations on the VM
    ```
    ssh-keygen -t rsa -f knewhub-vm-rails -C rails
    ```
    * Skip entering a passphrase by clicking `Enter` key
    * This creates two files: `knewhub-vm_rails` and `knewhub-vm-rails.pub`
    * Move the files to directory `~/.ssh` on the local machine if they are not already there
2. Add the SSH public key to the VM
    * Navigate to the VM instances page on Google Cloud console
    * Edit instance
    * SSH keys: copy the content of the `knewhub-vm-rails.pub` file
3. Ensure the VM is running then connect to it using this command. The `<VM_EXTERNAL_IP>` is the static external IP used in previous steps
    ```
    ssh -i ~/.ssh/knewhub-vm-rails rails@<VM_EXTERNAL_IP>
    ```
    * During the first connection, if the warning `The authenticity of host '<VM_EXTERNAL_IP>' can't be established` appears, enter `yes` to continue

### Installation of packages

1. Once connected to the VM, run `sudo apt-get update` to update the list of packages
2. The following packages need to be installed. Follow instructions from their respective documentation below
    1. Caddy
        * Used for the reverse proxy web server
        * https://caddyserver.com/docs/install#debian-ubuntu-raspbian
        * Edit the `Caddyfile` at `/etc/caddy/Caddyfile` to be:
            ```
            knewhub.com {
                reverse_proxy localhost:3000
            }
            ```
        * Check that the Caddy service is running with command `systemctl status caddy`. "Started Caddy." will appear on the logs
    2. Git
        * Used to install packages, and perform Git operations during deployment and within the Rails application
        * https://github.com/git-guides/install-git#debianubuntu
        * Check that Git was installed with command `git version`
    3. rbenv & ruby-build
        * Used to manage Ruby versions
        * https://github.com/rbenv/rbenv?tab=readme-ov-file#basic-git-checkout
            * Use the instructions for `bash`
            * Restart the shell with command `source ~/.bashrc`
            * Check that rbenv was installed with command `rbenv`. It should return a list of rbenv commands
        * https://github.com/rbenv/ruby-build?tab=readme-ov-file#clone-as-rbenv-plugin-using-git
    4. Ruby
        * Used to run our Rails application
        * Install dependencies
            * https://github.com/rbenv/ruby-build/wiki#ubuntudebianmint
        * Refer to the file `.ruby_version` for the version to install
        * Install Ruby with command `rbenv install <RUBY_VERSION>`
        * Apply this version globally with `rbenv global <RUBY_VERSION>``
        * Check that the correct Ruby version was installed with command `rbenv version`
    5. Redis
        * Used for storage by the Rails application
        * https://redis.io/docs/install/install-redis/install-redis-on-linux/
        * Check that Redis was installed with command `redis-server --version`
   6. Sidekiq
        * Used for background jobs by the Rails application
        * `gem install sidekiq`
        * `gem install bundler`
        * Check that Sidekiq was installed with command `sidekiq`. It should return logs with "Please point Sidekiq to a Rails application or a Ruby file to load your job classes with -r [DIR|FILE]."
    7. jq
        * Used to decrypt secrets from Secret Manager
        * `sudo apt-get install jq`
        * Check that jq was installed with command `jq`. It should return a list of jq commands
    8. PostgreSQL client
        * Used for database
        * `sudo apt install libpq-dev`

### Access secrets from Secret Manager

Environment variables are set by fetching secrets from Secret Manager. This is done by adding a script in the `.profile` file. This file is called every time the `rails` user logs in.

1. Edit the `.profile` file at `~/.profile` to be:
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
2. Reload the file with command `. ~/.profile`
3. Verify that environment variables are set with command `env`. It should return a list of environment variables and their values

### Set up SSH for GitHub

The Rails application will be cloned onto the VM using Git. To perform this operation, the VM needs to have its own keypair to SSH into GitHub.

[Reference Guide: Managing deploy keys](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys#deploy-keys)

1. In the VM, run `ssh-keygen -t ed25519 -C "noreply@knewhub.com"`. Click `Enter` to accept the file location and bypass setting a passphrase
2. The keypair should be saved in the directory `/home/rails/.ssh`
3. Edit the KnewHub directory on Github and add a deploy key. Give it read-only access
4. In the VM, run `git clone git@github.com:knewplay/knewhub.git`
5. Use command `ls` to confirm that the directory `knewhub` was created

### Start Rails application

1. In the VM, enter the `knewhub` directory
2. `bundle install` to install gems
3. `RAILS_ENV=production bin/rails assets:precompile` to pre-compile JavaScript and CSS assets
4. `bin/rails s -e production` to start a server. If the output is similar to below, then move on to the next steps:
    ```
    => Booting Puma
    => Rails 7.1.3 application starting in production 
    => Run `bin/rails server --help` for more startup options
    Puma starting in single mode...
    * Puma version: 6.4.2 (ruby 3.3.0-p0) ("The Eagle of Durango")
    *  Min threads: 5
    *  Max threads: 5
    *  Environment: production
    *          PID: 35434
    * Listening on http://0.0.0.0:3000
    Use Ctrl-C to stop
    ```
5. Stop the server

### systemd services

systemd will be used to manage all services that the Rails application requires. The systemd services used are as follow.

1. Caddy
    * The Caddy service was already set up as part of the package installation. No action is required
2. redis-server
    * The redis-server service was already set up as part of the package installation. No action is required
3. Sidekiq
    1. Create a `sidekiq.service` file at `/etc/systemd/system/sidekiq.service` with the following:
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
    2. `sudo systemctl daemon-reload` to reload systemd
    3. `sudo systemctl enable sidekiq` to enable the service
    4. `sudo systemctl start sidekiq` to start the service. If no output appears, then the service was successfully started
4. Knewhub (Rails application)
    1. Create a `knewhub.service` file at `/etc/systemd/system/knewhub.service` with the following:
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
    2. `sudo systemctl daemon-reload` to reload systemd
    3. `sudo systemctl enable knewhub` to enable the service
    4. `sudo systemctl start knewhub` to start the service. If no output appears, then the service was successfully started

#### Useful commands

* `systemctl list-units --type=service --state=running` to lists the systemd services that are currently running.
* `journalctl -f -u <SERVICE_NAME>` to view the logs for a given service.
* `sudo systemctl stop <SERVICE_NAME>` to stop a service

## Create additional storage disk attached to VM

### Create and attach disk

[Reference Guide: Add a persistent disk](https://cloud.google.com/compute/docs/disks/add-persistent-disk)

1. Navigate to the VM instances page on Google Cloud console
2. Edit instance: Additional disks -> Add new disk
    * Name: `knewhub-repos`
    * Disk source type: `blank disk`
    * Disk type: `Balanced persistent disk`
    * Size: `10` GB
    * Attachment setting: `Read/write`
    * Deletion rule: `Keep disk`

### Format and mount disk

[Reference Guide: Format and mount a non-boot disk on a Linux VM](https://cloud.google.com/compute/docs/disks/format-mount-disk-linux)

1. In the VM, identify name of `knewhub-repos` disk with command `ls -l /dev/disk/by-id/google-*`
    * Example output:
        ```sh
        lrwxrwxrwx 1 root root  9 Jan 30 14:32 /dev/disk/by-id/google-knewhub -> ../../sda
        lrwxrwxrwx 1 root root 10 Jan 30 14:32 /dev/disk/by-id/google-knewhub-part1 -> ../../sda1
        lrwxrwxrwx 1 root root 11 Jan 30 14:32 /dev/disk/by-id/google-knewhub-part14 -> ../../sda14
        lrwxrwxrwx 1 root root 11 Jan 30 14:32 /dev/disk/by-id/google-knewhub-part15 -> ../../sda15
        lrwxrwxrwx 1 root root  9 Jan 30 19:36 /dev/disk/by-id/google-knewhub-repos -> ../../sdb
        ```
    * The `knewhub-repos` disk name is `sdb`
2. `sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb` to format the disk
3. Remove the `.keep` file inside `/home/rails/knewhub/repos`. It will not be required after the disk is mounted
4. `sudo mount -o discard,defaults /dev/sdb /home/rails/knewhub/repos` to mount the directory where repositories will be located within the Rails application
5. Confirm that the disk is mounted by calling `df -h`
6. `sudo chown -R rails:rails /home/rails/knewhub/repos` to give the `rails` user access to the repos directory

### Persist mount after restart with fstab

1. `sudo blkid /dev/sdb` to find the UUID for the disk
2. Edit the `fstab` file at `/etc/stab` to add:
    ```sh
    UUID=<UUID_VALUE> /home/rails/knewhub/repos ext4 discard,defaults,nofail,user 0 2
    ```
3. `sudo umount /dev/sdb` to unmount the disk
4. `sudo mount -a` to mount the disk using fstab

## Deploy using Mina

### Add Mina script

1. `gem install mina`
2. `mina init`
3. Refer to [`config/deploy.rb`](./config/deploy.rb) and update variables as needed:
    * `:identify_file` location
    * UUID in `command %{sudo umount /dev/disk/by-uuid/<UUID> }`

### Remove existing `knewhub` directory

Mina will organize the `/home/rails/knewhub` directory into `releases`. The current release will be accessed using a symlink. For instance, `/home/rails/knewhub/current` points to `/home/rails/knewhub/releases/1`.

The `knewhub` directory currently set up does not use releases so it needs to me removed prior to deployment with Mina:
1. `sudo umount /dev/sdb` to unmount the `knewhub-repos` disk
2. `sudo rm knewhub -r`

### Modify systemd services and fstab to work with Mina releases

systemd and fstab files also need to be modified to make use of the "releases" folder structure:
1. Modify `/etc/systemd/system/sidekiq.service` and `/etc/systemd/system/knewhub.service` to have `WorkingDirectory=/home/rails/knewhub/current`
2. Modify `/etc/fstab` to use mount path `/home/rails/knewhub/current/repos`
3. From local terminal, run `mina deploy`.

## Display systemd logs on Cloud Logging

All systemd services have logs but they are accessible outside of the VM as it is. Google Cloud Logging will be used to keep track of the VM services logs, including the Rails application and the Sidekiq worker.

### Active Ops Agent

[Reference Guide: Installing the Ops Agent on individual VMs](https://cloud.google.com/logging/docs/agent/ops-agent/installation)

1. In the Google console, enable the Stackdriver Monitoring API
2. Add permission to the `compute-engine` service account for `Monitoring Metric Writer`
3. Install the latest version of the agent
    ```
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
    ```
4. Verify that the agent is running
    * In the Google console, navigate to: Monitoring -> Dashboard -> VM Instances
    * Click the "List" view
    * Under the column "Agent", the value `✅ Ops Agent` should appear

### View logs in Cloud Logging

1. In the Google console, navigate to: Logging -> Logs explorer
2. Selecting "VM Instance" in the "Resource Type" filter displays all the logs associated with VMs

The logs are showing but there is too much information displayed in the message, especially for the `knewhub` and `sidekiq` services.
```json
{
  ...
  "jsonPayload": {
    "message": "Jan 31 13:56:09 knewhub sidekiq[15817]: 2024-01-31T13:56:09.808Z pid=15817 tid=8xp INFO: Sidekiq 7.2.1 connecting to Redis with options {:size=>10, :pool_name=>\"internal\", :url=>\"redis://localhost:6379/1\"}"
  },
  ...
}
```

```json
{
  ...
  "jsonPayload": {
    "message": "Jan 31 14:01:12 knewhub rails[16858]: I, [2024-01-31T14:01:12.688702 #16858]  INFO -- : [6b5a34e3-65a6-453d-bb9e-d77e0c8e5a09] Processing by StaticPagesController#index as HTML"
  },
  ...
}
```
Moreover, the severity and service are indicated in the message field but they do not have their own JSON key, making it difficult to filter logs by severity level or service name.

In order to display just the right amount of information in the production logs, the Rails and Sidekiq loggers need to be modified and the Ops Agent configuration needs to include a custom processor.

### Modify logger for Rails

The default `config/environments/production.rb` file contains the following logger code:
```rb
# Log to STDOUT by default
config.logger = ActiveSupport::Logger.new(STDOUT)
  .tap  { |logger| logger.formatter = ::Logger::Formatter.new }
  .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

# Prepend all log lines with the following tags.
config.log_tags = [ :request_id ]
```

Modify it to have: 
```rb
config.logger = ActiveSupport::Logger.new(STDOUT)
config.logger.formatter = proc do |severity, _time, _progname, msg|
  "#{severity}: #{msg}\n"
end

# Do not prepend log lines with the following tags.
# config.log_tags = [ :request_id ]
```

The formatter now only displays the severity and message in the log. The Ops Agent already knows the time and the service associated with a log, so there is no need to duplicate this information.
The `:request_id` tag is removed as well.

In Cloud Logging, the logs coming from the `knewhub` service now have the following information:
```json
{
  ...
  "jsonPayload": {
    "message": "Jan 31 14:34:10 knewhub rails[17330]: INFO: Processing by StaticPagesController#index as HTML"
  },
  ...
}
```

### Modify logger for Sidekiq

Add the following logger configuration to `config/initializers/sidekiq.rb`:
```rb
Sidekiq.configure_server do |config|
  config.logger = Logger.new(STDOUT)
  config.logger.formatter = proc do |severity, _time, _progname, msg|
    "#{severity}: #{msg}\n"
  end
end
```

Note: I know that logger formatter code is not DRY. I had created a `lib/customer_formatter.rb` file but the production configuration file was not able to find it, despite having autoloading on.

In Cloud Logging, the logs coming from the `sidekiq` service now have the following information:
```json
{
  ...
  "jsonPayload": {
    "message": "Jan 31 14:30:36 knewhub sidekiq[17607]: INFO: Sidekiq 7.2.1 connecting to Redis with options {:size=>10, :pool_name=>\"internal\", :url=>\"redis://localhost:6379/1\"}"
  },
  ...
}
```

### Enable custom formatter for Ops Agent

[Reference Guide: Configuring the Ops Agent](https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/configuration)

Modify `/etc/google-cloud-ops-agent/config.yaml`:
```yml
logging:
  processors:
    systemd_processor:
      type: parse_regex
      field: message
      regex: "^(?<datetime>[a-zA-Z]+ [\d]+ [\d]+:[\d]+:[\d]+) (?<vm_name>[a-zA-Z]+) (?<process_name>[a-zA-Z]+)(?<process_id>\[\d+\])(: )(?<severity>EMERG|ALERT|CRIT|ERROR|WARN|NOTICE|INFO|DEBUG)?(:\s)?(?<message>(.|\\n)*)$"
    move_severity:
      type: modify_fields
      fields:
        severity:
          move_from: jsonPayload.severity
  service:
    pipelines:
      default_pipeline:
        processors: [systemd_processor, move_severity]
```

In the VM, restart the agent to see the changes in logs: `sudo systemctl restart google-cloud-ops-agent"*"`.
In the Google console the logs should now be properly formatted.

```json
{
  ...
  "jsonPayload": {
    "message": "Processing by StaticPagesController#index as HTML",
    "process_id": "[18543]",
    "vm_name": "knewhub",
    "process_name": "rails",
    "datetime": "Jan 31 14:37:41"
  },
  ...
  "severity": "INFO",
  ...
}
```

```json
{
  ...
  "jsonPayload": {
    "vm_name": "knewhub",
    "datetime": "Jan 31 14:37:05",
    "message": "Sidekiq 7.2.1 connecting to Redis with options {:size=>10, :pool_name=>\"internal\", :url=>\"redis://localhost:6379/1\"}",
    "process_name": "sidekiq",
    "process_id": "[18164]"
  },
  ...
  "severity": "INFO",
  ...
}
```

## Experiments that did not make it into the final solution

### Connection to the SQL database using Cloud SQL Auth Proxy

The Google documentation on [connecting to Cloud SQL from Compute Engine](https://cloud.google.com/sql/docs/postgres/connect-compute-engine) presents three options: private IP, public IP and Cloud SQL Auth Proxy.

The initial plan was to use Cloud SQL Auth Proxy since it was presented as the most secure option.

The VM and SQL instance were able to be connected using the proxy, but the Rails application would not be able to find the database.

We ended up moving to using a public IP by setting it up the connection directly in the Rails application database configuration (`config/database.yml`).

### Running the Rails application on Docker

The original plan was to run the Rails application on Docker. A CI/CD pipeline was already set up to build a Docker image and push it to Artifact Registry every time a new commit takes place on the `main` branch.

We wanted to have the Rails application on Docker but all other support systems running directly on the Linux VM using systemd.

The Sidekiq systemd service would not cooperate with the Rails application on Docker. We ended up moving the Rails application directly on the VM, and deploying semi-automatically using Mina. i.e. the `mina deploy` commands needs to be called on a local nachine but the rest of the process is automatic.

### Using Cloud Storage FUSE (instead of an attached disk)

The original plan was to use Cloud Storage to store the repositories that are on KnewHub. The storage bucket would have been mounted to the VM through GCS FUSE.

This solution did not work in the end because the `Git clone` operation is not supported by GCS Fuse. Refer to [issue 539](https://github.com/GoogleCloudPlatform/gcsfuse/issues/539).