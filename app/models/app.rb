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
  
  before_create :store_identifier
  
  after_create do |app|
    app.send_later(:store_icon!)
    app.send_later(:store_description!)
  end
  
  class << self
    
    def extract_attributes(attributes)
      attributes.symbolize_keys.slice(:name, :item_id, :icon_url, :artist_name, :artist_id, :genre, :genre_id)
    end
    
  end
  
  def to_param
    identifier
  end
  
  def url
    AppStore.view_software_url(item_id)
  end
  
  def most_recently_added_install
    installs(:order => 'created_at').last
  end
  
  def average_rating
    if attributes.keys.include?('average_rating')
      rating = self['average_rating']
    else
      rating = installs.average(:rating)
    end
    rating ? rating.to_f.round : nil
  end
  
  def number_of_installs
    if attributes.keys.include?('number_of_installs')
      return self['number_of_installs']
    else
      return app.installs.size
    end
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
  
  def store_identifier
    identifier = name.strip.gsub(/[^a-z0-9]+/i, '-').downcase
    count = self.class.count(:conditions => ['identifier = ? OR identifier LIKE ?', identifier, "#{identifier}~%"])
    identifier = "#{identifier}~#{count}" if count > 0
    self.identifier = identifier
  end
  
end
