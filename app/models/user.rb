class User < ActiveRecord::Base
  
  acts_as_authentic do |config|
    config.merge_validates_length_of_login_field_options(:if => :active?)
    config.merge_validates_format_of_login_field_options(:if => :active?, :with => /\A\w[\w\-_]+\z/, :message => I18n.t('error_messages.login_invalid', :default => "should use only letters, numbers, hyphens, and underscores."))
    config.merge_validates_length_of_password_field_options(:if => :active?)
    config.require_password_confirmation(false)
  end
  
  attr_accessible :email, :login, :password, :active
  
  has_many :installs, :order => 'created_at', :dependent => :destroy
  has_many :apps, :through => :installs
  has_many :connections
  has_many :connected_users, :through => :connections
  has_many :connected_installs, :through => :connected_users, :source => :installs
  has_many :connected_apps, :through => :connected_installs, :source => :app
  
  has_many :inbound_connections, :class_name => 'Connection', :foreign_key => 'connected_user_id'
  has_many :inbound_connected_users, :through => :inbound_connections, :source => :user
  
  has_many :invitations, :order => 'created_at'
  has_many :syncs, :order => 'created_at'
  
  named_scope :active, :conditions => { :active => true }
  named_scope :inactive, :conditions => { :active => false }
  
  class << self
    
    def send_invitations(maximum_number_of_invitations = nil)
      users = User.inactive.find(:all, :order => 'created_at', :limit => maximum_number_of_invitations)
      users.each { |user| user.invite! }
    end
    
  end
  
  def installed_apps
    App.find(installs.current.installed.map(&:app_id))
  end
  
  def uninstalled_apps
    App.find(installs.current.uninstalled.map(&:app_id))
  end
  
  def invite!
    UserMailer.deliver_invitation(self)
    invitations.create!
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
    user == self
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
  
  def synchronize(new_apps, sync)
    original_apps = installed_apps
    found_apps = []
    new_apps.each do |attributes|
      app_attributes = App.extract_attributes(attributes)
      install_attributes = Install.extract_attributes(attributes)
      if app = App.find_by_name(app_attributes[:name])
        found_apps << app
      else
        app = App.create!(app_attributes)
      end
      latest_install = installs.of_app(app).last
      raw_xml = install_attributes[:raw_xml]
      state = nil
      if latest_install.nil?
        state = 'Initial'
      elsif !latest_install.installed?
        state = 'Install'
      elsif latest_install.differs_from?(raw_xml)
        state = 'Update'
      end
      if state
        latest_install.update_attributes(:current => false) if latest_install
        installs.create!(install_attributes.merge(:current => true, :state => state, :app => app, :sync => sync))
      end
    end
    missing_apps = original_apps - found_apps
    missing_apps.each do |app|
      create_uninstall_for!(app, sync)
    end
  end

  private
  
  def create_uninstall_for!(app, sync)
    latest_install = installs.of_app(app).last
    latest_install_attributes = Install.extract_attributes(latest_install.attributes)
    latest_install.update_attributes(:current => false)
    installs.create!(latest_install_attributes.merge(:current => true, :state => 'Uninstall', :installed => false, :app => app, :sync => sync))
  end
  
  def connected_apps_optimized(conditions)
    App.all(
      :select => %{
        apps.*,
        COUNT(installs.id) AS number_of_installs,
        AVG(installs.rating) AS average_rating,
        MAX(installs.created_at) AS maximum_created_at
      },
      :joins => %{
        INNER JOIN installs
          ON (apps.id = installs.app_id)
      },
      :conditions => conditions,
      :group => 'apps.id',
      :order => 'maximum_created_at DESC'
    )
  end
  
  def app_ids_sql
    %{
      SELECT apps.id FROM apps
        INNER JOIN installs ON (apps.id = installs.app_id)
        INNER JOIN users ON (installs.user_id = #{id})
    }
  end
  
  def connected_app_ids_sql
    %{
      SELECT apps.id FROM apps
        INNER JOIN installs ON (apps.id = installs.app_id)
        INNER JOIN users ON (installs.user_id = users.id)
        INNER JOIN connections ON (users.id = connections.connected_user_id)
        WHERE (connections.user_id = #{id})
    }
  end
  
end
