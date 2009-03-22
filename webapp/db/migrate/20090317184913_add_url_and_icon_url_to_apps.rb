class AddUrlAndIconUrlToApps < ActiveRecord::Migration
  
  def self.up
    add_column :apps, :item_id, :string
    add_column :apps, :icon_url, :string
  end

  def self.down
    remove_column :apps, :item_id
    remove_column :apps, :icon_url
  end
  
end
