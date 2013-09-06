source 'http://rubygems.org'

gem 'activesupport', '~>3.2'
gem 'log4r'
gem 'mail'
gem 'thor'
gem 'icalendar'
gem 'redcarpet'


group :test do
  gem 'rspec'
  gem 'cucumber'
  gem 'open4'
  gem 'timecop'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  if RUBY_PLATFORM =~ /linux/i
    gem 'libnotify'
    gem 'rb-inotify', :require => false
  end
end

group :development do
  gem 'debugger'
end

group :deploy do
  gem 'capistrano', '~> 3.0.0.pre13'
end