class CreateApps < ActiveRecord::Migration
  
  def self.up
    create_table :apps do |t|
      t.string :name
      t.string :item_id
      t.string :icon_url
      t.timestamps
    end
  end

  def self.down
    drop_table :apps
  end
  
end
