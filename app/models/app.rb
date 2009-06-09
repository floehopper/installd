class App < ActiveRecord::Base
  
  has_many :installs, :dependent => :destroy
  has_many :users, :through => :installs
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  validates_presence_of :item_id
  
  validates_presence_of :icon_url
  
  def to_param
    "#{id}-#{name.gsub(/[^a-z0-9]+/i, '-')}"
  end
  
  def url
    "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=#{item_id}&mt=8"
  end
  
end
