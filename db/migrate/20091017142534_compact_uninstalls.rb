class CompactUninstalls < ActiveRecord::Migration
  
  def self.up
    User.all.each do |user|
      user.apps.each do |app|
        last_install_was_uninstall = false
        user.installs.of_app(app).each do |install|
          if install.installed
            last_install_was_uninstall = false
          else
            if last_install_was_uninstall
              puts "*** destroying install with id: #{install.id}"
              install.destroy
            end
            last_install_was_uninstall = true
          end
        end
      end
    end
  end
  
  def self.down
    # irreversible
  end
  
end
