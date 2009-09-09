class Install < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :app
  
  validates_presence_of :user
  validates_presence_of :app
  
  validates_uniqueness_of :user_id, :scope => :app_id
  validates_uniqueness_of :app_id, :scope => :user_id
  
  validates_presence_of :price
  validates_presence_of :display_price
  validates_presence_of :released_at
  validates_presence_of :store_code
  validates_presence_of :software_version_bundle_id
  validates_presence_of :software_version_external_identifier
  
  def can_be_updated_by?(updating_user)
    user == updating_user
  end
  
end
