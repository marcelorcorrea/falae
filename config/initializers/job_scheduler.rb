# return if not running puma in production
return unless $PROGRAM_NAME.include?('puma') && Rails.env == 'production'

require 'rufus-scheduler'

scheduler = Rufus::Scheduler.singleton lockfile: 'rufus-scheduler.lock'

if scheduler.up?
  scheduler.cron '0 2 * * *' do
    User.cleanup_unactivated
  end
end
