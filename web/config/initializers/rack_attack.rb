class Rack::Attack
    # Configure Cache
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    # Throttle all requests by IP (60rpm)
    throttle('req/ip', :limit => 300, :period => 5.minutes) do |req|
      req.ip unless req.path.start_with?('/assets', 'public')
    end

    # Throttle POST requests to /login by IP
    throttle('logins/ip', :limit => 30, :period => 30.minutes) do |req|
      if req.path == '/login' && req.post?
        req.ip
      end
    end
  end
