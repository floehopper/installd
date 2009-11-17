class RemoveRawXmlFromSyncSessions < ActiveRecord::Migration
  
  def self.up
    remove_column :sync_sessions, :raw_xml
    FileUtils.mkdir_p(SyncSession.base_path)
  end
  
  def self.down
    FileUtils.rm_rf(SyncSession.base_path)
    add_column :sync_sessions, :raw_xml, :text, :limit => 1.megabyte
  end
  
end
