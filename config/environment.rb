# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'authlogic', :version => '2.0.13'
  config.gem 'mislav-will_paginate', :version => '2.3.11', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'hpricot', :version => '0.8.1'
  config.gem 'mime-types', :version => '1.16', :lib => 'mime/types'
  config.gem 'newrelic_rpm', :version => '2.9.3'
  config.gem 'simplehttp', :version => '0.1.3'
  config.gem 'whenever', :lib => false, :source => 'http://gemcutter.org/'
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  config.action_mailer.smtp_settings = {
    :tls => true,
    :address => "smtp.gmail.com",
    :port => "587",
    :domain => "installd.com",
    :authentication => :plain,
    :user_name => ENV["INSTALLD_GMAIL_USERNAME"],
    :password => ENV["INSTALLD_GMAIL_PASSWORD"]
  }
  
  # the ExceptionNotifier configuration is placed in an after_initialize block as a workaround for a bug [1] as explained in this comment [2].
  # [1] https://rails.lighthouseapp.com/projects/8995/tickets/49-exception_notification-productionrb-configuration-wiped-by-double-load
  # [2] https://rails.lighthouseapp.com/projects/8995/tickets/49-exception_notification-productionrb-configuration-wiped-by-double-load#ticket-49-7
  config.after_initialize do
    ExceptionNotifier.exception_recipients = %w(admin@installd.com)
    ExceptionNotifier.sender_address = %{Installd #{Rails.env.capitalize} Error" <noreply@installd.com>}
    ExceptionNotifier.email_prefix = "[installd-#{Rails.env}] "
  end
  
end
