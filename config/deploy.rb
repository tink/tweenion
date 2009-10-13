# =============================================================================
# Capistrano receipes for tweenion
# =============================================================================

# =============================================================================
# APPLICATION VARIABLES
# =============================================================================
set :application, "tweenion"

# =============================================================================
# SCM VARIABLES
# =============================================================================
default_run_options[:pty] = true
set :repository, "git@github.com:fagiani/tweenion.git"
set :repository_cache, "cached-copy"

set :scm, "git"
set :scm_verbose, true
set :branch, "master"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# =============================================================================
# ROLES
# =============================================================================
case ENV['CONNECTION']
when 'labs'
  set :host, 'tweenion.labs.tink.com.br'
  set :user, 'tweenion'
when 'prod'
  set :host, 'tweenion.com'
  set :user, 'tweenion'
else #remote
  set :host, '127.0.0.1'
  set :user, 'tweenion'
end

role :web, host
role :app, host
role :db,  host, :primary => true

# =============================================================================
# SERVER VARIABLES
# =============================================================================
set :use_sudo, false
set :deploy_via, :remote_cache

case ENV['RAILS_ENV']
when 'production'
  set :deploy_to, "/home/#{user}/production"
else
  set :deploy_to, "/home/#{user}/development"
end

set :rails_env, ENV['RAILS_ENV'] || 'development'

# =============================================================================
# TASKS
# =============================================================================
after "deploy:symlink", "deploy:update_crontab"
after "deploy:update_code", "gems:install"

namespace :gems do
  desc "Installs and builds gems as specified in environment.rb"
  task :install, :roles=>:app do
    run <<-CMD
      cd #{current_release} &&
      rake gems:install RAILS_ENV=#{fetch :rails_env} &&
      rake gems:build RAILS_ENV=#{fetch :rails_env}
    CMD
  end 
end

namespace :deploy do
  desc <<-DESC
    Do a custom deployment.
  DESC

  task :default do
    transaction do
      #      puts "Checking out the latest project version..."
      update_code
      #      puts "Disabling web proxy..."
      web.disable
      #      puts "Making a database backup..."
      db.backup
      #      puts "Migrating the database..."
      migrate
      #      puts "Updating current version..."
      symlink
      #      puts "Restarting passenger"
      restart
      #      puts "Enabling web proxy..."
      web.enable
      #      puts "That's all!"
    end
  end

  desc <<-DESC
    Prepares one or more servers for deployment. Before you can use any \
    of the Capistrano deployment tasks with your project, you will need to \
    make sure all of your servers have been prepared with `cap deploy:setup'. When \
    you add a new server to your cluster, you can easily run the setup task \
    on just that server by specifying the HOSTS environment variable:

      $ cap HOSTS=new.server.com deploy:setup

    It is safe to run this task on servers that have already been set up; it \
    will not destroy any deployed revisions or data.
  DESC

  task :setup, :except => { :no_release => true } do
    config_path = File.join(shared_path, "config")
    backup_path = File.join(shared_path, "backup")
    shared_children = %w(system log pids sessions cache)

    dirs = [deploy_to, releases_path, shared_path, config_path, backup_path]
    dirs += shared_children.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"

    #touch files to help creating new environment
    database_yaml = File.join(config_path, "database.yml")
    rsync_yaml = File.join(config_path, "rsync.yml")
    environment_rb = File.join(config_path, "environment.rb")

    run <<-CMD
      touch #{database_yaml} #{environment_rb} #{rsync_yaml}
    CMD
  end

  desc <<-DESC
    [internal] Touches up the released code. This is called by update_code \
    after the basic deploy finishes. It assumes a Rails project was deployed, \
    so if you are deploying something else, you may want to override this \
    task with your own environment's requirements.

    This task will make the release group-writable (if the :group_writable \
    variable is set to true, which is the default). It will then set up \
    symlinks to the shared directory for the log, system, and tmp/pids \
    directories, and will lastly touch all assets in public/images, \
    public/stylesheets, and public/javascripts so that the times are \
    consistent (so that asset timestamping works).  This touch process \
    is only carried out if the :normalize_asset_timestamps variable is \
    set to true, which is the default.
  DESC

  task :finalize_update, :except => { :no_release => true } do
    run <<-CMD
      rm -rf #{latest_release}/log &&
      rm -rf #{latest_release}/public/system &&
      rm -rf #{latest_release}/tmp/{cache,pids,sessions} &&
      rm -rf #{latest_release}/config/rsync.yml &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/cache #{latest_release}/tmp/cache &&
      ln -s #{shared_path}/pids #{latest_release}/tmp/pids &&
      ln -s #{shared_path}/sessions #{latest_release}/tmp/sessions &&
      ln -s #{shared_path}/log #{latest_release}/log &&
      ln -s #{shared_path}/system #{latest_release}/public/system &&
      ln -s #{shared_path}/config/rsync.yml #{latest_release}/config/rsync.yml &&
      ln -s #{shared_path}/config/database.yml #{latest_release}/config/database.yml
    CMD

    run <<-CMD
      rm -rf #{latest_release}/db/backup &&
      ln -nfs #{shared_path}/backup #{latest_release}/db/backup
    CMD

    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = %w(images stylesheets javascripts).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end

  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  desc "check current path"
  task :check_path, :roles => :app do
    run "echo $PATH"
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run <<-CMD
      cd #{current_path} &&
      whenever --update-crontab #{application}
    CMD
  end

  namespace :web do
    desc <<-DESC
      Present a maintenance page to visitors.
      $ cap deploy:web:disable \\
            REASON="hardware upgrade" \\
            UNTIL="12pm Central Time"
    DESC

    task :disable, :roles => :web, :except => { :no_release => true } do
      require 'erb'
      on_rollback { run "rm -f #{shared_path}/system/maintenance.html || true" }
      reason = ENV['REASON']
      deadline = ENV['UNTIL']
      template = File.read(File.join(File.dirname(__FILE__), '..', 'app', 'views', 'layouts', "maintenance.html.erb"))
      result = ERB.new(template).result(binding)
      put result, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end

  namespace :db do
    desc 'Backup database'
    task :backup, :roles => :db do
      rake = fetch(:rake, "rake")
      rails_env = fetch(:rails_env, "development")

      run <<-CMD
        cd #{current_release}; #{rake} RAILS_ENV=#{rails_env} system:backup
      CMD
    end
  end
end
