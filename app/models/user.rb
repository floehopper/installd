class User < ActiveRecord::Base
  
  acts_as_authentic
  
  has_many :installs, :dependent => :destroy
  has_many :apps, :through => :installs
  
  def to_param
    login
  end
  
end
