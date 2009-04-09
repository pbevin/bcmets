set :application, "bcmets"
set :repository,  "pete@petebevin.com:git/bcmets"
set :user, "pete"
set :use_sudo, false

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/www/#{application}-new"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git

role :app, "petebevin.com"
role :web, "petebevin.com"
role :db,  "petebevin.com", :primary => true


namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end
