class AddPurchaseDateToInstalls < ActiveRecord::Migration
  
  def self.up
    add_column :installs, :purchase_date, :datetime
    add_index :installs, :purchase_date
    Install.all.each do |install|
      parser = IphoneAppPlistParser.new(install.raw_xml)
      install.update_attributes(:purchase_date => parser.attributes[:purchaseDate])
    end
  end
  
  def self.down
    remove_index :installs, :purchase_date
    remove_column :installs, :purchase_date
  end
  
end
