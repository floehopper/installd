class AddDescriptionToApps < ActiveRecord::Migration
  
  def self.up
    add_column :apps, :description, :text
    App.all.each do |app|
      sleep(5)
      app.save!
    end
  end
  
  def self.down
    remove_column :apps, :description
  end
  
end
