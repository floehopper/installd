class RenameInstallsPurchaseDateToPurchasedAt < ActiveRecord::Migration
  
  def self.up
    remove_index :installs, :purchase_date
    rename_column :installs, :purchase_date, :purchased_at
    add_index :installs, :purchased_at
  end
  
  def self.down
    remove_index :installs, :purchased_at
    rename_column :installs, :purchased_at, :purchase_date
    add_index :installs, :purchase_date
  end
  
end
