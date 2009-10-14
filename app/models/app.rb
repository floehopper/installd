class App < ActiveRecord::Base
  
  has_many :installs, :dependent => :destroy
  has_many :users, :through => :installs
  
  has_attached_file :icon
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  validates_presence_of :item_id
  validates_presence_of :icon_url
  validates_presence_of :artist_name
  validates_presence_of :artist_id
  validates_presence_of :genre
  validates_presence_of :genre_id
  
  before_validation :store_icon
  
  def url
    "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=#{item_id}&mt=8"
  end
  
  def most_recently_added_install
    installs(:order => 'created_at').last
  end
  
  def average_rating
    installs.average(:rating)
  end
  
  private
  
  def store_icon
    if icon_url && icon.nil?
      self.icon = URLTempfile.new(icon_url)
    end
  end
  
end
