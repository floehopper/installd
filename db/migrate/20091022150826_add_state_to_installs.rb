class AddStateToInstalls < ActiveRecord::Migration
  
  def self.up
    add_column :installs, :state, :string
    add_index :installs, :state
    
    User.all.each do |user|
      user.installs.group_by(&:app_id).each do |(app_id, installs)|
        state = 'Initial'
        installs.each do |install|
          if install.installed?
            install.state = state
            state = 'Update'
          else
            install.state = 'Uninstall'
            state = 'Install'
          end
          unless install.save
            puts "Unable to save install: #{install.inspect}"
            puts install.errors.full_messages.join("\n")
          end
        end
      end
    end
  end
  
  def self.down
    remove_index :installs, :state
    remove_column :installs, :state
  end
  
end
