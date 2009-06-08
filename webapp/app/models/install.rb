class Install < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :app
  
  validates_presence_of :user
  validates_presence_of :app
  
end
