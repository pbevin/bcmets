set :application, "bcmets"
set :repository,  "git://github.com/pbevin/bcmets.git"
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

  desc "Re-establish symlinks"
  task :after_symlink do
    run <<-CMD
      rm -fr #{release_path}/db/sphinx &&
      ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx
    CMD
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end
after "deploy:symlink", "deploy:update_crontab"
