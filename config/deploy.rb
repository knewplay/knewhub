# frozen_string_literal: true

require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)

set :application_name, 'knewhub'
set :domain, 'knewhub.com'
set :deploy_to, '/home/rails/knewhub'
set :repository, 'git@github.com:knewplay/knewhub.git'
set :branch, 'main'
set :user, 'rails'
set :identity_file, '~/.ssh/knewhub_vm_rails'

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  invoke :'rbenv:load'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  command %{sudo systemctl daemon-reload}
  command %{sudo systemctl enable sidekiq}
  command %{sudo systemctl enable knewhub}
  command %{sudo systemctl start sidekiq}
  command %{sudo systemctl start knewhub}
end

desc 'Deploys the current version to the server.'
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    invoke :'git:clone'
    command %{ source ~/.profile } # Fetch environment variables
    invoke :'deploy:link_shared_paths'
    # invoke :'bundle:install' # Override default 'bundle:install' task to take into account deprecation warnings from Bundler
    comment %(Installing gem dependencies using Bundler)
    command %(#{fetch(:bundle_bin)} config set --local without '#{fetch(:bundle_withouts)}')
    command %(#{fetch(:bundle_bin)} config set --local path '#{fetch(:bundle_path)}')
    command %(#{fetch(:bundle_bin)} config set --local deployment 'true')
    command %(#{fetch(:bundle_bin)} install)
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %(mkdir -p tmp/)
        command %(touch tmp/restart.txt)
        command %{sudo umount /dev/disk/by-uuid/c1a04b38-4b31-4ebd-a4e7-cf3f3ddf9b59} # Unmount disk for repos at previous release location
        command %{sudo mount -a} # Mount disk for repos at current release location
        command %{sudo systemctl restart sidekiq}
        command %{sudo systemctl restart knewhub} # Restart app
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before or after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
