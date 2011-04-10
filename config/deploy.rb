$:.unshift(File.expand_path("~/.rvm/lib"))
require 'rvm/capistrano'

set :rails_env, :production
set :application, "contesta"

# this is used for rvm 
set :rvm_ruby_string, 'ree@contesta'
set :rvm_type, :user

set :scm, :git
set :repository,  "git://dev.c-base.org/contesta/contesta.git"

# on the remote host
set :applicationdir, "/var/www/contesta_meego_competition"
set :config_dir, "/etc/rails/contesta_meego_competition"
set :user , "ruby"
set :group , "ruby"
set :server, :unicorn

set :use_sudo, false
set :nginx_path_prefix, "/etc/nginx"

set :branch, 'meego-competition'
set :scm_verbose, true
set :deploy_to, applicationdir
set :deploy_via, :remote_cache

role :web, "may.base45.de"                          # Your HTTP server, Apache/etc
role :app, "may.base45.de" 
role :db,  "may.base45.de", :primary => true # This is where Rails migrations will run

require 'bundler/capistrano'
#role :db,  "your slave db-server here"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
  desc "symlink db conf"
    task :symlink_db, :roles => [ :app ] do
	    run "ln -fs #{config_dir}/database.yml #{release_path}/config/database.yml"
	    run "ln -fs #{config_dir}/unicorn.rb #{release_path}/unicorn.rb"
    end
  end

after 'deploy:symlink',	'deploy:symlink_db'

set :unicorn_binary, "bundle exec unicorn"
set :unicorn_config, "#{current_path}/unicorn.rb"
set :unicorn_pid, "#{current_path}/../../shared/pids/unicorn.pid"

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "cd #{current_path} && #{try_sudo} #{unicorn_binary} -c #{unicorn_config} -E #{rails_env} -D"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "#{try_sudo} kill `cat #{unicorn_pid}`"
  end
  task :graceful_stop, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s QUIT `cat #{unicorn_pid}`"
  end
  task :reload, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} kill -s USR2 `cat #{unicorn_pid}`"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end
end
