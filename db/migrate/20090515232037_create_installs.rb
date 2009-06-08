class CreateInstalls < ActiveRecord::Migration
  
  def self.up
    create_table :installs do |t|
      t.integer :user_id
      t.integer :app_id
      t.timestamps
    end
  end
  
  def self.down
    drop_table :installs
  end
  
end
