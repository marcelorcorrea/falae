# return if running rails console/command, spring preloader or rake task
return if defined?(Rails::Console) || defined?(Rails::Command) ||
  $PROGRAM_NAME.include?('spring') || File.basename($0) == 'rake'

require 'rufus-scheduler'

scheduler = Rufus::Scheduler.singleton lockfile: 'rufus-scheduler.lock'

if scheduler.up?
  scheduler.cron '0 2 * * *' do
    User.cleanup_unactivated
  end

  scheduler.join
end
