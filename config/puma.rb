# Puma configuration
threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count

port        ENV['PORT']     || 4567
environment ENV['RACK_ENV'] || 'development'

# Only use workers on platforms that support it (not Windows)
if Gem.win_platform?
  # Single mode for Windows
else
  workers Integer(ENV['WEB_CONCURRENCY'] || 2)
  preload_app!
end