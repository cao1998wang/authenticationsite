# Set your full path to application.
app_dir = File.expand_path('../../', __FILE__)
shared_dir = File.expand_path('../../../shared/', __FILE__)
app_name = "Maimai"
 
# Set unicorn options
worker_processes 2
preload_app true
timeout 30
 
GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true
 
# Fill path to your app
working_directory app_dir
 
# Set up socket location
listen "#{shared_dir}/sockets/unicorn.#{app_name}.sock", :backlog => 64
 
# Loging
stderr_path "#{shared_dir}/log/unicorn.#{app_name}.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.#{app_name}.stdout.log"
 
# Set master PID location
pid "#{shared_dir}/pids/unicorn.#{app_name}.pid"
 
before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  sleep 1
end
 
after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
  defined?(Rails) and Rails.cache.respond_to?(:reconnect) and Rails.cache.reconnect
end
 
before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = "#{app_dir}/Gemfile"
end
