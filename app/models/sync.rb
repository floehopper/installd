class Sync < ActiveRecord::Base
  
  belongs_to :user
  has_many :installs
  
  validates_presence_of :user
  
end