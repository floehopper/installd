class SyncSession < ActiveRecord::Base
  
  belongs_to :user
  has_many :events
  
  validates_presence_of :user
  
  validate_on_create :previous_sync_session_complete
  
  attr_writer :raw_xml
  
  after_save :write_raw_xml
  
  def parse
    parser = MultipleIphoneAppPlistParser.new(raw_xml)
    apps = parser.unique_apps
    user.synchronize(apps, self)
    status = 'success'
  rescue => e
    status = "failure: #{e}"
    logger.error(e)
    logger.error(e.backtrace.join("\n"))
  ensure
    update_attributes(:status => status)
  end
  
  def previous_sync_session_complete
    previous_sync_session = user.sync_sessions.last
    if previous_sync_session && previous_sync_session.status.nil?
      errors.add_to_base('Previous sync session not yet complete')
    end
  end
  
  def self.base_path
    File.expand_path(File.join(Rails.root, 'public', 'system', 'sync-sessions'))
  end
  
  def path_to_raw_xml
    File.join(self.class.base_path, "#{id}.xml")
  end
  
  def write_raw_xml
    File.open(path_to_raw_xml, 'w') do |file|
      file.write(raw_xml)
      file.sync unless file.fsync
    end
  end
  
  def raw_xml
    @raw_xml ||= read_raw_xml
  end
  
  def read_raw_xml
    raw_xml = nil
    File.open(path_to_raw_xml) do |file|
      raw_xml = file.read
    end
    raw_xml
  end
  
end