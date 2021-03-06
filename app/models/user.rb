class User < ActiveRecord::Base
  
  acts_as_authentic do |config|
    config.merge_validates_length_of_login_field_options(:if => :active?)
    config.merge_validates_format_of_login_field_options(:if => :active?, :with => /\A\w[\w\-_]+\z/, :message => I18n.t('error_messages.login_invalid', :default => "should use only letters, numbers, hyphens, and underscores."))
    config.merge_validates_length_of_password_field_options(:if => :active?)
    config.require_password_confirmation(false)
  end
  
  attr_accessible :email, :login, :password, :active
  
  has_many :events, :order => 'created_at', :dependent => :destroy
  has_many :apps, :through => :events
  has_many :reviews, :order => 'created_at', :dependent => :destroy
  has_many :connections
  has_many :connected_users, :through => :connections
  has_many :connected_events, :through => :connected_users, :source => :events
  has_many :connected_apps, :through => :connected_events, :source => :app
  
  has_many :inbound_connections, :class_name => 'Connection', :foreign_key => 'connected_user_id'
  has_many :inbound_connected_users, :through => :inbound_connections, :source => :user
  
  has_many :invitations, :order => 'created_at'
  has_many :sync_sessions, :order => 'created_at'
  
  named_scope :active, :conditions => { :active => true }
  named_scope :inactive, :conditions => { :active => false }
  
  class << self
    
    def send_invitations(maximum_number_of_invitations = nil)
      users = User.inactive.find(:all, :order => 'created_at', :limit => maximum_number_of_invitations)
      users.each { |user| user.invite! }
    end
    
  end
  
  def installed_apps(options = {})
    app_ids = events.current.installed.map(&:app_id)
    options[:conditions] = ['id IN (?)', app_ids]
    App.find(:all, options)
  end
  
  def uninstalled_apps
    App.find(events.current.uninstalled.map(&:app_id))
  end
  
  def invite!
    UserMailer.deliver_invitation(self)
    invitations.create!
  end
  
  def deliver_password_reset!
    reset_perishable_token!
    UserMailer.deliver_password_reset(self)
  end
  
  def last_invited_at
    invitations.last ? invitations.last.created_at : nil
  end
  
  def to_param
    login
  end
  
  def can_connect?(user)
    !me?(user) && !already_connected?(user)
  end
  
  def me?(user)
    self == user
  end
  
  def already_connected?(user)
    connected_users.include?(user)
  end
  
  def connected_apps_including_mine
    connected_apps_optimized(%{
      apps.id IN (#{app_ids_sql})
      OR
      apps.id IN (#{connected_app_ids_sql})
    })
  end
  
  def connected_apps_in_common
    connected_apps_optimized(%{
      apps.id IN (#{app_ids_sql})
      AND
      apps.id IN (#{connected_app_ids_sql})
    })
  end
  
  def connected_apps_not_in_common
    connected_apps_optimized(%{
      apps.id NOT IN (#{app_ids_sql})
      AND
      apps.id IN (#{connected_app_ids_sql})
    })
  end
  
  def synchronize(new_apps, sync_session)
    original_apps = installed_apps
    found_apps = []
    new_apps.each do |attributes|
      app_attributes = App.extract_attributes(attributes)
      event_attributes = Event.extract_attributes(attributes)
      if app = App.find_by_name(app_attributes[:name])
        found_apps << app
      else
        app = App.create!(app_attributes)
      end
      previous_event = latest_event_for(app)
      new_event = events.build(event_attributes.merge(:app => app, :sync_session => sync_session))
      state = new_event.state_based_on(previous_event)
      if state
        new_event.state = state
        new_event.save!
      end
    end
    missing_apps = original_apps - found_apps
    missing_apps.each do |app|
      event_attributes = Event.extract_attributes(latest_event_for(app).attributes)
      events.create!(event_attributes.merge(:state => 'Uninstall', :app => app, :sync_session => sync_session))
    end
  end
  
  def latest_event_for(app)
    events.of_app(app).last
  end
  
  def create_manual_uninstall!(app, sync_session)
    previous_event = latest_event_for(app)
    if previous_event && previous_event.installed?
      event_attributes = Event.extract_attributes(previous_event.attributes)
      events.create!(event_attributes.merge(:state => 'Ignore', :app => app, :sync_session => sync_session))
    end
  end
  
  private
  
  def connected_apps_optimized(conditions)
    conditions = "events.current = 1 AND events.state NOT IN ('Uninstall', 'Ignore') AND (#{conditions})"
    App.all(
      :select => %{
        apps.*,
        COUNT(events.id) AS number_of_installs,
        MAX(events.created_at) AS maximum_created_at
      },
      :joins => %{
        INNER JOIN events
          ON (apps.id = events.app_id)
      },
      :conditions => conditions,
      :group => 'apps.id',
      :order => 'maximum_created_at DESC'
    )
  end
  
  def app_ids_sql
    %{
      SELECT apps.id FROM apps
        INNER JOIN events ON (apps.id = events.app_id)
        INNER JOIN users ON (events.user_id = #{id})
    }
  end
  
  def connected_app_ids_sql
    %{
      SELECT apps.id FROM apps
        INNER JOIN events ON (apps.id = events.app_id)
        INNER JOIN users ON (events.user_id = users.id)
        INNER JOIN connections ON (users.id = connections.connected_user_id)
        WHERE (connections.user_id = #{id})
    }
  end
  
end
