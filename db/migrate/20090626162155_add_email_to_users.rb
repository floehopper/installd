class AddEmailToUsers < ActiveRecord::Migration
  
  def self.up
    add_column :users, :email, :string
    add_index :users, :email
  end
  
  def self.down
    remove_index :users, :email
    remove_column :users, :email
  end
  
end
