namespace :falae do
  desc 'Restart Falae App'
  task restart: :environment do
    system("kill -9 $(cat #{Rails.root}/tmp/pids/puma.pid)")
    system('bundle exec puma -e production -d')
  end

  desc 'Bundle install'
  task bundle_install: :environment do
    system('bundle install')
  end

  desc 'Bundle install, assets precompile, and restart'
  task restart_after_deploy: [:environment, 'falae:bundle_install', 'assets:precompile', 'falae:restart']
end
