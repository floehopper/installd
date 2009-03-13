class User < ActiveRecord::Base
  
  has_many :installs, :dependent => :destroy
  has_many :apps, :through => :installs
  
  validates_presence_of :login
  validates_uniqueness_of :login
  
end
