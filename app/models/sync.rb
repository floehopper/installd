class Sync < ActiveRecord::Base
  
  belongs_to :user
  has_many :events
  
  validates_presence_of :user
  
  validate_on_create :previous_sync_complete
  
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
  
  def previous_sync_complete
    previous_sync = user.syncs.last
    if previous_sync && previous_sync.status.nil?
      errors.add_to_base('Previous sync not yet complete')
    end
  end
  
end