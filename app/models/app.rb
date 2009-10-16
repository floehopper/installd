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
  
  validate :should_have_at_least_one_install
  
  after_save do |app|
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
    installs.average(:rating)
  end
  
  def store_icon!
    unless icon
      self.icon = URLTempfile.new(icon_url)
      save!
    end
  end
  
  def store_description!
    unless description
      sleep(5)
      app = AppStore.create_app(item_id)
      self.description = app.description
      save!
    end
  end
  
  private
  
  def should_have_at_least_one_install
    unless installs.size > 0
      errors.add_to_base('should have at least one install')
    end
  end
  
end
