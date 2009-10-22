class AddIdentifierToApps < ActiveRecord::Migration
  
  def self.up
    add_column :apps, :identifier, :string
    add_index :apps, :identifier
    App.all.each do |app|
      app.store_identifier
      unless app.save
        puts "Unable to save app: #{app.inspect}"
        puts app.errors.full_messages.join("\n")
      end
    end
  end
  
  def self.down
    remove_index :apps, :identifier
    remove_column :apps, :identifier
  end
  
end
