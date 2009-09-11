class User < ActiveRecord::Base
  
  acts_as_authentic do |config|
    config.merge_validates_length_of_login_field_options(:if => :active?)
    config.merge_validates_format_of_login_field_options(:if => :active?, :with => /\A\w[\w\-_]+\z/, :message => I18n.t('error_messages.login_invalid', :default => "should use only letters, numbers, hyphens, and underscores."))
    config.merge_validates_length_of_password_field_options(:if => :active?)
    config.require_password_confirmation(false)
  end
  
  attr_accessible :email, :login, :password, :active
  
  has_many :installs, :dependent => :destroy
  has_many :apps, :through => :installs
  has_many :connections
  has_many :connected_users, :through => :connections
  has_many :connected_installs, :through => :connected_users, :source => :installs
  has_many :connected_apps, :through => :connected_installs, :source => :app
  has_many :invitations, :order => 'created_at'
  
  named_scope :active, :conditions => { :active => true }
  named_scope :inactive, :conditions => { :active => false }
  
  class << self
    
    def send_invitations(maximum_number_of_invitations = nil)
      users = User.inactive.find(:all, :order => 'created_at', :limit => maximum_number_of_invitations)
      users.each { |user| user.invite! }
    end
    
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
  
  private
  
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
