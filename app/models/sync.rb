class Sync < ActiveRecord::Base
  
  belongs_to :user
  has_many :events
  
  validates_presence_of :user
  
end