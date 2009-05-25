

set :application, "mpi"
set :repository,  "git@github.com:andrewn/most-popular-then.git"
set :scm, :git
set :branch, "master"
# Options for git/hub deployment
ssh_options[:forward_agent] = true
default_run_options[:pty] = true


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "~/apps/#{application}"

role :app, "andrew@andrewnicolaou.co.uk"
#role :web, "your web-server here"
#role :db,  "your db-server here", :primary => true


#
# Override some of the default tasks to do nothing
#  as they're rails-+specific+
#
namespace :deploy do
  # :setup, :update, :update_code, :finalize_update, :symlink
  [:restart].each do |default_task|
    task default_task do 
       logger.trace("this command is empty: #{default_task}")
    end
  end  
  
  desc <<-DESC
    Push files not stored in git up to server
  DESC
  task :push_non_scm_files do
    put "This does nothing as yet..."
  end
  
  desc <<-DESC
    After the code has been updated, ensure that links are updated...
  DESC
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

    # mkdir -p is making sure that the directories are there for some SCM's that don't
    # save empty folders
    run <<-CMD
      rm -rf #{latest_release}/log &&
      ln -s #{shared_path}/log #{latest_release}/log
    CMD
  end
end

task :test_write_perms do
  logger.trace("current_release: #{current_release}")
  #run "touch #{current_release}/this_is_a_writable_file"
end