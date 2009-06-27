class AddPerishableTokenToUsers < ActiveRecord::Migration
  
  def self.up
    add_column :users, :perishable_token, :string
    add_index :users, :perishable_token
  end
  
  def self.down
    remove_index :users, :perishable_token
    remove_column :users, :perishable_token
  end
  
end
