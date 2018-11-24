# return if not running puma in production
return unless $PROGRAM_NAME.include?('puma') && Rails.env == 'production'

require 'rufus-scheduler'

scheduler = Rufus::Scheduler.singleton lockfile: "#{Rails.root}/rufus-scheduler.lock"

rufus_logger = Logger.new "#{Rails.root}/log/rufus.log"

if scheduler.up?
  scheduler.cron '0 2 * * *' do
    rufus_logger.warn "Running Cleanup Users #{Time.now}"
    unactive_users = User.cleanup_unactivated
    if unactive_users.any?
      unactive_users.each do |user|
        rufus_logger.warn "  Deleted user: #{user.name}, #{user.email}, #{user.created_at}"
      end
    else
      rufus_logger.warn '  No unactivated users.'
    end
  end
end
