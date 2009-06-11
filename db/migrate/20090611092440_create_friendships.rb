class CreateFriendships < ActiveRecord::Migration
  
  def self.up
    create_table :friendships, :force => true do |t|
      t.integer :user_id
      t.integer :friend_id
      t.timestamps
    end
    add_index :friendships, :user_id
    add_index :friendships, :friend_id
  end
  
  def self.down
    remove_index :friendships, :friend_id
    remove_index :friendships, :user_id
    mind
    drop_table :friendships
  end
  
end
