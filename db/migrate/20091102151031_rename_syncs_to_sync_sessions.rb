class RenameSyncsToSyncSessions < ActiveRecord::Migration
  
  def self.up
    remove_index :syncs, :user_id
    rename_table :syncs, :sync_sessions
    add_index :sync_sessions, :user_id
    
    remove_index :events, :sync_id
    rename_column :events, :sync_id, :sync_session_id
    add_index :events, :sync_session_id
  end
  
  def self.down
    remove_index :events, :sync_session_id
    rename_column :events, :sync_session_id, :sync_id
    add_index :events, :sync_id
    
    remove_index :sync_sessions, :user_id
    rename_table :sync_sessions, :syncs
    add_index :syncs, :user_id
  end
  
end
