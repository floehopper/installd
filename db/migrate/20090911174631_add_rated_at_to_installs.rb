class AddRatedAtToInstalls < ActiveRecord::Migration
  
  def self.up
    add_column :installs, :rated_at, :datetime
  end
  
  def self.down
    remove_column :installs, :rated_at
  end
  
end
