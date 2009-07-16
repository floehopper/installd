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
  
  named_scope :inactive, :conditions => { :active => false }
  
  class << self
    
    def send_invitations(maximum_number_of_invitations = nil)
      users = User.inactive.find(:all, :order => 'created_at', :limit => maximum_number_of_invitations)
      users.each { |user| UserMailer.deliver_invitation(user) }
    end
    
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
  
end
