class User < ActiveRecord::Base
  
  acts_as_authentic
  
  has_many :installs, :dependent => :destroy
  has_many :apps, :through => :installs
  has_many :friendships
  has_many :friends, :through => :friendships
  
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
