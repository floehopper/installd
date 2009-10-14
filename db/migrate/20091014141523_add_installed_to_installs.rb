class AddInstalledToInstalls < ActiveRecord::Migration
  
  def self.up
    add_column :installs, :installed, :boolean, :default => true
    add_index :installs, :installed
  end
  
  def self.down
    remove_index :installs, :installed
    remove_column :installs, :installed
  end
  
end
