class RemoveNullConstraintsOnUsers < ActiveRecord::Migration
  
  def self.up
    change_column :users, :login, :string, :null => true
    change_column :users, :crypted_password, :string, :null => true
    change_column :users, :password_salt, :string, :null => true
    change_column :users, :persistence_token, :string, :null => true
    change_column :users, :login_count, :integer, :default => 0, :null => true
  end
  
  def self.down
    change_column :users, :login, :string, :null => false
    change_column :users, :crypted_password, :string, :null => false
    change_column :users, :password_salt, :string, :null => false
    change_column :users, :persistence_token, :string, :null => false
    change_column :users, :login_count, :integer, :default => 0, :null => false
  end
  
end
