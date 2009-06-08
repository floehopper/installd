class User < ActiveRecord::Base
  
  acts_as_authentic
  
  has_many :installs, :dependent => :destroy
  has_many :apps, :through => :installs
  
  validates_presence_of :login
  validates_uniqueness_of :login
  
  def to_param
    "#{id}-#{login.gsub(/[^a-z0-9]+/i, '-')}"
  end
  
end