class AddRawXmlToApps < ActiveRecord::Migration
  
  def self.up
    add_column :apps, :raw_xml, :text
  end
  
  def self.down
    remove_column :apps, :raw_xml
  end
  
end
