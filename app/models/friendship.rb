class Friendship < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :friend, :class_name => 'User'
  
  validates_presence_of :user
  validates_presence_of :friend
  
  validates_uniqueness_of :user_id, :scope => :friend_id
  validates_uniqueness_of :friend_id, :scope => :user_id
  
end