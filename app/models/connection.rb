class Connection < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :connected_user, :class_name => 'User'
  
  validates_presence_of :user
  validates_presence_of :connected_user
  
  validates_uniqueness_of :user_id, :scope => :connected_user_id
  validates_uniqueness_of :connected_user_id, :scope => :user_id
  
  named_scope :for_user, lambda { |user| { :conditions => { :connected_user_id => user.id } } }
  
end