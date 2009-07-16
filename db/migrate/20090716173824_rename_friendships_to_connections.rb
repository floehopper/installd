class RenameFriendshipsToConnections < ActiveRecord::Migration
  
  def self.up
    rename_table :friendships, :connections
    rename_column :connections, :friend_id, :connected_user_id
  end
  
  def self.down
    rename_column :connections, :connected_user_id, :friend_id
    rename_table :connections, :friendships
  end
  
end
