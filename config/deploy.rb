require "bundler/capistrano"
#require 'capistrano/ext/multistage'
#set :stages, ["staging", "production"]
#set :default_stage, "staging"

#############################
####### SERVER SETUP ########
#############################

### LIVE SITE ####
#set :app_path, "/home/tigeorgia/webapps"
#set :application,"tenderwatch"
#set :deploy_to, "#{app_path}/#{application}"
#set :assets_path, "#{app_path}/tendermonitor_static"
#role :web, "web331.webfaction.com"
#role :app, "web331.webfaction.com"
#role :db, "web331.webfaction.com", :primary => true

### STAGING ####
set :app_path, "/home/tigeorgia/webapps"
set :application, "rainbow"
set :deploy_to, "#{app_path}/#{application}"
set :assets_path, "#{deploy_to}_static"
set :rails_env, "production"
set :environment, "production"
role :web, "web331.webfaction.com"
role :app, "web331.webfaction.com"
role :db, "web331.webfaction.com", :primary => true


##########################
###### DEPLOY CODE #######
##########################

set :scm, "git"
set :branch, "master"
set :repository, "git://github.com/tigeorgia/rainbow.git"
default_run_options[:pty] = true
set :scm_username, "EtienneBaque"
set :user, "tigeorgia"
set :use_sudo, false

namespace :deploy do
  desc "Restart nginx"
  task :restart do
    run "#{deploy_to}/bin/restart"
  end
end

set :default_environment, {
    'PATH' => "#{deploy_to}/bin:$PATH",
    'GEM_HOME' => "#{deploy_to}/gems"
}

namespace :gems do
  task :bundle, :roles => :app do
    run "cd #{release_path} && bundle install --deployment --without development test"
  end
end

namespace :custom do
  task :settings_config, :roles => :app do
    run "cp -f #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    #run "cp -f #{shared_path}/config/setup_mail.rb #{release_path}/config/initializers/setup_mail.rb"
  end
end

namespace :custom do
  task :deploy_static_assets, :roles => :app do
    run "cp -r -f #{release_path}/public/assets/* #{assets_path}"
  end
end

namespace :db do
  task :migrate, :roles => :db do
    run "cd #{release_path} && RAILS_ENV=#{environment} rake db:migrate"
  end
end

before  'deploy:assets:precompile', "custom:settings_config"
after "deploy:update_code", "custom:settings_config"
after "deploy:update_code", "gems:bundle"
after "deploy:update_code", "custom:deploy_static_assets"
after "deploy:update_code", "db:migrate"