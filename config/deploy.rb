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

namespace :bundler do
  task :install do
    run("gem install bundler --source=http://gemcutter.org")
  end

  task :symlink_vendor do
    shared_gems = File.join(shared_path, 'vendor/bundler_gems')
    release_gems = "#{release_path}/vendor/bundler_gems"
    %w(cache gems specifications).each do |sub_dir|
      shared_sub_dir = File.join(shared_gems, sub_dir)
      run("mkdir -p #{shared_sub_dir} && mkdir -p #{release_gems} && ln -s #{shared_sub_dir} #{release_gems}/#{sub_dir}")
    end
  end

  task :bundle_new_release do
    bundler.symlink_vendor
    run("cd #{release_path} && bundle install --without=test")
  end
end

# hook into capistrano's deploy task
after 'deploy:update_code', 'bundler:bundle_new_release'
