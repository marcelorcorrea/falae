require 'puma/daemon'

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 4 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
# port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment 'production'

app_dir = File.expand_path("../../..", __FILE__)

tmp_dir = "#{app_dir}/tmp"

# Set up socket location
sockets_dir = "#{tmp_dir}/sockets"
Dir.mkdir sockets_dir unless Dir.exist? sockets_dir
bind "unix://#{sockets_dir}/falae.sock"

# Logging
log_dir = "#{tmp_dir}/logs"
Dir.mkdir log_dir unless Dir.exist? log_dir
stdout_redirect "#{log_dir}/puma.stdout.log", "#{log_dir}/puma.stderr.log", true

# Set master PID and state locations
pids_dir = "#{tmp_dir}/pids"
Dir.mkdir pids_dir unless Dir.exist? pids_dir
pidfile "#{pids_dir}/puma.pid"
state_path "#{pids_dir}/puma.state"
activate_control_app


# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
workers ENV.fetch("WEB_CONCURRENCY") { 5 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
# preload_app!

# If you are preloading your application and using Active Record, it's
# recommended that you close any connections to the database before workers
# are forked to prevent connection leakage.
#
# before_fork do
#   ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
# end

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted, this block will be run. If you are using the `preload_app!`
# option, you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, as Ruby
# cannot share connections between processes.
#
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
#

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

daemonize
