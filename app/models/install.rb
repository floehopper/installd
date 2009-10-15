class Install < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :app
  
  validates_presence_of :user
  validates_presence_of :app
  
  validates_presence_of :price
  validates_presence_of :display_price
  validates_presence_of :released_at
  validates_presence_of :store_code
  validates_presence_of :software_version_bundle_id
  validates_presence_of :software_version_external_identifier
  
  before_save :store_hashcode
  
  class << self
    
    def extract_attributes(attributes)
      attributes.symbolize_keys.slice(:price, :display_price, :purchased_at, :released_at, :store_code, :software_version_bundle_id, :software_version_external_identifier, :raw_xml)
    end
    
    def generate_hashcode(raw_xml)
      Digest::MD5.hexdigest(raw_xml)
    end
    
  end
  
  def can_be_updated_by?(updating_user)
    user == updating_user
  end
  
  def store_hashcode
    self.hashcode = self.class.generate_hashcode(raw_xml)
  end
  
end
