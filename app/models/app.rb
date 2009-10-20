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
  
  after_create do |app|
    app.send_later(:store_icon!)
    app.send_later(:store_description!)
  end
  
  class << self
    
    def extract_attributes(attributes)
      attributes.symbolize_keys.slice(:name, :item_id, :icon_url, :artist_name, :artist_id, :genre, :genre_id)
    end
    
  end
  
  def url
    AppStore.view_software_url(item_id)
  end
  
  def most_recently_added_install
    installs(:order => 'created_at').last
  end
  
  def average_rating
    rating = self['average_rating'] || installs.average(:rating)
    rating ? rating.to_f.round : nil
  end
  
  def number_of_installs
    self['number_of_installs'].to_i || app.installs.size
  end
  
  def store_icon!
    self.icon = URLTempfile.new(icon_url)
    save!
  end
  
  def store_description!
    sleep(5)
    app = AppStore.create_app(item_id)
    update_attributes!(:description => app.description)
  end
  
end
