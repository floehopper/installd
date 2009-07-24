class App < ActiveRecord::Base
  
  has_many :installs, :dependent => :destroy
  has_many :users, :through => :installs
  
  has_attached_file :icon
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  validates_presence_of :item_id
  
  validates_presence_of :icon_url
  
  before_validation :store_icon
  
  def url
    "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=#{item_id}&mt=8"
  end
  
  private
  
  def store_icon
    self.icon = URLTempfile.new(icon_url)
  end
  
end
