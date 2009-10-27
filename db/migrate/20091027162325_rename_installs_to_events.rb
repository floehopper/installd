class RenameInstallsToEvents < ActiveRecord::Migration
  
  def self.up
    remove_index :installs, :current
    remove_index :installs, :state
    remove_index :installs, :sync_id
    remove_index :installs, :hashcode
    remove_index :installs, :installed
    remove_index :installs, :purchased_at
    remove_index :installs, :app_id
    remove_index :installs, :user_id
    
    rename_table :installs, :events
    
    add_index :events, :user_id
    add_index :events, :app_id
    add_index :events, :purchased_at
    add_index :events, :installed
    add_index :events, :hashcode
    add_index :events, :sync_id
    add_index :events, :state
    add_index :events, :current
  end
  
  def self.down
    remove_index :events, :current
    remove_index :events, :state
    remove_index :events, :sync_id
    remove_index :events, :hashcode
    remove_index :events, :installed
    remove_index :events, :purchased_at
    remove_index :events, :app_id
    remove_index :events, :user_id
    
    rename_table :events, :installs
    
    add_index :installs, :user_id
    add_index :installs, :app_id
    add_index :installs, :purchased_at
    add_index :installs, :installed
    add_index :installs, :hashcode
    add_index :installs, :sync_id
    add_index :installs, :state
    add_index :installs, :current
  end
  
end
