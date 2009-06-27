class User < ActiveRecord::Base
  
  acts_as_authentic do |config|
    config.merge_validates_length_of_login_field_options(:if => :active?)
    config.merge_validates_format_of_login_field_options(:if => :active?)
    config.merge_validates_length_of_password_field_options(:if => :active?)
    config.require_password_confirmation(false)
  end
  
  attr_accessible :email, :login, :password, :active
  
  has_many :installs, :dependent => :destroy
  has_many :apps, :through => :installs
  has_many :friendships
  has_many :friends, :through => :friendships
  has_many :friends_installs, :through => :friends, :source => :installs
  
  def to_param
    login
  end
  
  def can_make_friends?(user)
    !me?(user) && !already_friends?(user)
  end
  
  def me?(user)
    user == self
  end
  
  def already_friends?(user)
    friends.include?(user)
  end
  
end
