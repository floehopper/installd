default_run_options[:pty] = true

set :application, "installd"

set :deploy_to, "/var/rails/#{application}"

set :scm, :git
set :repository,  "git@git.floehopper.org:#{application}"

server "argonaut.slice", :app, :web, :db, :primary => true

after "deploy:update_code", "symlink:db"
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
  
end

namespace :gems do
  
  desc "build native extensions for gems"
  task :build, :roles => :app do
    run("cd #{release_path}; RAILS_ENV=production rake gems:build")
  end
  
end

