class RemoveInvalidApps < ActiveRecord::Migration
  
  def self.up
    apps = App.all
    apps.each do |app|
      app.destroy unless app.valid?
    end
  end
  
  def self.down
    # irreversible
  end
  
end
