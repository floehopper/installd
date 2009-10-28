class RemoveInstalledFromEvents < ActiveRecord::Migration
  
  def self.up
    remove_column :events, :installed
  end
  
  def self.down
    add_column :events, :installed, :boolean, :default => true
  end
  
end
