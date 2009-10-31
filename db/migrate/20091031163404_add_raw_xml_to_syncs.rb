class AddRawXmlToSyncs < ActiveRecord::Migration
  
  def self.up
    add_column :syncs, :raw_xml, :text, :limit => 1.megabyte
  end
  
  def self.down
    remove_column :syncs, :raw_xml
  end
  
end
