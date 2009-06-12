class AddIndexesToInstalls < ActiveRecord::Migration
  
  def self.up
    add_index :installs, :user_id
    add_index :installs, :app_id
  end
  
  def self.down
    remove_index :installs, :app_id
    remove_index :installs, :user_id
  end
  
end
