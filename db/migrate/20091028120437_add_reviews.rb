class AddReviews < ActiveRecord::Migration
  
  def self.up
    create_table :reviews, :force => true do |t|
      t.integer :user_id
      t.integer :app_id
      t.timestamps
    end
    add_index :reviews, :user_id
    add_index :reviews, :app_id
  end
  
  def self.down
    remove_index :reviews, :app_id
    remove_index :reviews, :user_id
    drop_table :reviews
  end
  
end
