class Install < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :app
  belongs_to :sync
  
  validates_presence_of :user
  validates_presence_of :app
  validates_presence_of :sync
  
  validates_presence_of :price
  validates_presence_of :display_price
  validates_presence_of :released_at
  validates_presence_of :store_code
  validates_presence_of :software_version_bundle_id
  validates_presence_of :software_version_external_identifier
  
  named_scope :of_app, lambda { |app| { :conditions => ['app_id = ?', app.id] } }
  named_scope :current, :conditions => { :current => true }
  named_scope :installed, :conditions => { :installed => true }
  named_scope :uninstalled, :conditions => { :installed => false }
  
  before_create :store_hashcode
  
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
  
  def matches?(raw_xml)
    hashcode = self.class.generate_hashcode(raw_xml)
    (self.hashcode == hashcode) && self.installed
  end
  
  def differs_from?(raw_xml)
    !matches?(raw_xml)
  end
  
end
