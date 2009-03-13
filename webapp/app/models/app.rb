class App < ActiveRecord::Base
  
  has_many :installs, :dependent => :destroy
  has_many :users, :through => :installs
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
end
