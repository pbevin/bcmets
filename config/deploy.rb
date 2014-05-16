require 'bundler/capistrano'
load 'deploy/assets'

set :rvm_ruby_string, '2.1.1'
set :rvm_type, :system
require 'rvm/capistrano'

set :application, "bcmets"
set :repository,  "git://github.com/pbevin/bcmets.git"
set :user, "pete"
set :use_sudo, false
set :public_children, "images"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

role :app, "www.bcmets.org"
role :web, "www.bcmets.org"
role :db,  "www.bcmets.org", primary: true


namespace :deploy do
  task :start, roles: :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, roles: :app do
    # Do nothing.
  end

  desc 'Fix up database.yml'
  task :dbconfig do
    run "cp #{shared_path}/database.yml #{release_path}/config/database.yml"
  end
  before "deploy:finalize_update", "deploy:dbconfig"

  desc "Restart Application"
  task :restart, roles: :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  desc "Re-establish symlinks"
  task :link_sphinx do
    run <<-CMD
      rm -fr #{release_path}/db/sphinx &&
      ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx
    CMD
  end
  before "deploy:finalize_update", "deploy:link_sphinx"

  desc "Update the crontab file"
  task :update_crontab, roles: :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
  #before "deploy:finalize_update", "deploy:update_crontab"
end
