class AddDescriptionToApps < ActiveRecord::Migration
  
  def self.up
    add_column :apps, :description, :text
    App.all.each { |app| app.save! }
  end
  
  def self.down
    remove_column :apps, :description
  end
  
end
