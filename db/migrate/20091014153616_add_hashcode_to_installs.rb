class AddHashcodeToInstalls < ActiveRecord::Migration
  
  def self.up
    add_column :installs, :hashcode, :string
    add_index :installs, :hashcode
    store_install_hashcodes
  end
  
  def self.down
    remove_index :installs, :hashcode
    remove_column :installs, :hashcode
  end
  
  def self.store_install_hashcodes
    installs = Install.all
    installs.each do |install|
      unless install.save
        error_messages = install.errors.full_messages.join("\n")
        puts "Install #{install.id} has errors: #{error_messages}"
      end
    end
  end
  
end
