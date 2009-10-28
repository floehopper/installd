class App < ActiveRecord::Base
  
  has_many :events, :order => 'created_at', :dependent => :destroy
  has_many :users, :through => :events
  
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
    
    def popular(options = {})
      options = {
        :select => 'apps.*, COUNT(events.id) AS number_of_installs',
        :joins => 'LEFT OUTER JOIN events ON events.app_id = apps.id',
        :conditions => ['events.current = ? AND events.state <> ?', true, 'Uninstall'],
        :group => 'apps.id',
        :order => 'number_of_installs DESC, created_at DESC'
      }.merge(options)
      find(:all, options)
    end
    
    def rated(options = {})
      options = {
        :select => 'apps.*, AVG(events.rating) AS average_rating, COUNT(events.rating) AS number_of_ratings',
        :joins => 'LEFT OUTER JOIN events ON events.app_id = apps.id',
        :conditions => ['events.current = ? AND events.state <> ?', true, 'Uninstall'],
        :group => 'apps.id',
        :order => 'average_rating DESC, created_at DESC'
      }.merge(options)
      find(:all, options)
    end
    
  end
  
  def to_param
    identifier
  end
  
  def url
    AppStore.view_software_url(item_id)
  end
  
  def most_recently_added_event
    events(:order => 'created_at').last
  end
  
  def average_rating
    if attributes.keys.include?('average_rating')
      rating = self['average_rating']
    else
      rating = events.average(:rating)
    end
    rating ? rating.to_f.round : nil
  end
  
  def number_of_installs
    if attributes.keys.include?('number_of_installs')
      number_of_installs = self['number_of_installs']
      return number_of_installs ? number_of_installs.to_i : nil
    else
      return events.current.installed.size
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
