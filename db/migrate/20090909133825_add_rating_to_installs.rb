class AddRatingToInstalls < ActiveRecord::Migration
  
  def self.up
    add_column :installs, :rating, :integer
  end
  
  def self.down
    remove_column :installs, :rating
  end
  
end
