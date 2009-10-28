class Review < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :app
  
  validates_uniqueness_of :user_id, :scope => :app_id
  validates_uniqueness_of :app_id, :scope => :user_id
  
end