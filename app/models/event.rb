class Event < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :app
  belongs_to :sync_session
  
  validates_presence_of :user
  validates_presence_of :app
  validates_presence_of :sync_session
  
  validates_presence_of :price
  validates_presence_of :display_price
  validates_presence_of :released_at
  validates_presence_of :store_code
  validates_presence_of :software_version_bundle_id
  validates_presence_of :software_version_external_identifier
  
  named_scope :of_app, lambda { |app| { :conditions => ['app_id = ?', app.id] } }
  named_scope :current, :conditions => { :current => true }
  named_scope :installed, :conditions => ['state NOT IN (?)', %w(Uninstall Ignore)]
  named_scope :uninstalled, :conditions => ['state IN (?)', %w(Uninstall Ignore)]
  
  before_create :store_hashcode
  before_create :update_current
  
  class << self
    
    def extract_attributes(attributes)
      attributes.symbolize_keys.slice(:price, :display_price, :purchased_at, :released_at, :store_code, :software_version_bundle_id, :software_version_external_identifier, :raw_xml)
    end
    
    def generate_hashcode(raw_xml)
      Digest::MD5.hexdigest(raw_xml)
    end
    
  end
  
  def store_hashcode
    self.hashcode = self.class.generate_hashcode(raw_xml)
  end
  
  def matches?(event)
    store_hashcode
    event.store_hashcode
    self.hashcode == event.hashcode
  end
  
  def differs_from?(event)
    !matches?(event)
  end
  
  def purchased_after?(event)
    purchased_at > event.purchased_at
  end
  
  def update_current
    latest_event = user.latest_event_for(app)
    if latest_event
      latest_event.update_attributes(:current => false)
    end
    self.current = true
  end
  
  def state_allowed_based_on?(previous_event)
    if previous_event
      case previous_event.state
      when 'Initial', 'Install', 'Update'
        case state
        when 'Update'
          return differs_from?(previous_event) && purchased_after?(previous_event)
        when 'Uninstall', 'Ignore'
          return true
        else
          return false
        end
      when 'Uninstall'
        return state == 'Install'
      when 'Ignore'
        return false
      end
    else
      if sync_session == user.sync_sessions.first
        return state == 'Initial'
      else
        return state == 'Install'
      end
    end
    return false
  end
  
  def state_based_on(previous_event)
    if previous_event
      case previous_event.state
      when 'Initial', 'Install', 'Update'
        if differs_from?(previous_event) && purchased_after?(previous_event)
          return 'Update'
        end
      when 'Uninstall'
        return 'Install'
      end
    else
      if sync_session == user.sync_sessions.first
        return 'Initial'
      else
        return 'Install'
      end
    end
    return nil
  end
  
  def installed?
    %w(Initial Install Update).include?(state)
  end
  
  def uninstalled?
    %w(Uninstall Ignore).include?(state)
  end
  
end
