namespace :puma do
  desc 'Restart server'
  task restart: :environment do
    system("kill -9 $(cat #{Rails.root}/tmp/pids/puma.pid)")
    system('bundle exec puma -e production -d')
  end
end
