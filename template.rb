gem "haml"
gem "simple_form"
gem "cancan"
gem "newrelic_rpm"
gem "therubyracer"
gem "less-rails"
gem "twitter-bootstrap-rails"

gem_group :production do
  gem "pg"
  gem "unicorn"
end

gem_group :development do
  gem "better_errors"
end

gem_group :development, :test do
  gem "rspec-rails"
  gem "sqlite3"
end

run "bundle"

run "rm app/views/layouts/application.html.erb"
run "rm app/assets/images/rails.png"
run "rm public/index.html"

generate("bootstrap:install", "less")
generate("bootstrap:layout", "application fixed")
generate(:controller, "pages home")
route "root to: 'pages#home'"

file 'Procfile', <<-CODE
web: bundle exec unicorn -p $PORT -E $RACK_ENV -c config/unicorn.rb
CODE

file 'config/unicorn.rb', <<-CODE
# config/unicorn.rb
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end 

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
CODE

git :init
git add: "."
git commit: "-a -m 'Initial commit'"
