class App < ActiveRecord::Base
  
  has_many :events, :order => 'created_at', :dependent => :destroy
  has_many :users, :through => :events
  has_many :reviews, :order => 'created_at', :dependent => :destroy
  
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
        :conditions => ['events.current = ? AND events.state NOT IN (?)', true, %w(Uninstall Ignore)],
        :group => 'apps.id',
        :order => 'number_of_installs DESC, created_at DESC'
      }.merge(options)
      find(:all, options)
    end
    
    def rated(options = {})
      options = {
        :select => 'apps.*, AVG(reviews.rating) AS average_rating, COUNT(reviews.rating) AS number_of_ratings, MAX(reviews.updated_at) AS last_rated_at',
        :joins => 'LEFT OUTER JOIN reviews ON reviews.app_id = apps.id',
        :group => 'apps.id',
        :order => 'average_rating DESC, last_rated_at DESC, created_at DESC'
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
  
  def review_by_user(user)
    review = reviews.detect { |review| review.user == user }
    review || reviews.build(:user => user)
  end
  
  def average_rating
    if attributes.keys.include?('average_rating')
      rating = self['average_rating']
    else
      rating = reviews.average(:rating)
    end
    rating ? rating.to_f : nil
  end
  
  def number_of_ratings
    if attributes.keys.include?('number_of_ratings')
      number_of_ratings = self['number_of_ratings']
    else
      number_of_ratings = reviews.with_rating.size
    end
    number_of_ratings ? number_of_ratings.to_i : nil
  end
  
  def number_of_installs
    if attributes.keys.include?('number_of_installs')
      number_of_installs = self['number_of_installs']
    else
      number_of_installs = events.current.installed.size
    end
    number_of_installs ? number_of_installs.to_i : nil
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
