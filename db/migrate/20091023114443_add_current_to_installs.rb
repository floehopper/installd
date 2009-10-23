class AddCurrentToInstalls < ActiveRecord::Migration
  
  def self.up
    add_column :installs, :current, :boolean
    add_index :installs, :current
    
    User.all.each do |user|
      user.installs.group_by(&:app_id).each do |(app_id, installs)|
        unless installs.last.update_attributes(:current => true)
          puts "Unable to update install: #{install.inspect}"
          puts install.errors.full_messages.join("\n")
        end
      end
    end
  end

  def self.down
    remove_index :installs, :current
    remove_column :installs, :current
  end
  
end
