default_run_options[:pty] = true

set :application, "installd"

set :deploy_to, "/var/rails/#{application}"

set :scm, :git
set :repository,  "git@git.floehopper.org:#{application}"

server "argonaut.slice", :app, :web, :db, :primary => true

set :shared_children, shared_children + %w(cache)

after "deploy:update_code", "symlink:db"
after "deploy:update_code", "symlink:cache"
after "deploy:update_code", "gems:build"

namespace :deploy do

  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
end

namespace :symlink do
  
  desc "symlink database yaml" 
  task :db do
    run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
  end
  
  desc "symlink folder for file store cache"
  task :cache do
    run "ln -s #{shared_path}/cache #{release_path}/tmp/cache"
  end
  
end

namespace :gems do
  
  desc "build native extensions for gems"
  task :build, :roles => :app do
    run("cd #{release_path}; RAILS_ENV=production rake gems:build")
  end
  
end

namespace :delayed_job do
  desc "Start delayed_job process"
  task :start, :roles => :app do
    run "cd #{current_path}; script/delayed_job start -- production"
  end

  desc "Stop delayed_job process"
  task :stop, :roles => :app do
    run "cd #{current_path}; script/delayed_job stop -- production"
  end

  desc "Restart delayed_job process"
  task :restart, :roles => :app do
    run "cd #{current_path}; script/delayed_job restart -- production"
  end
end
after "deploy:start", "delayed_job:start"
after "deploy:stop", "delayed_job:stop"
after "deploy:restart", "delayed_job:restart"

namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :app do
    run "cd #{release_path} && whenever --update-crontab #{application}"
  end
end
after "deploy:symlink", "deploy:update_crontab"
