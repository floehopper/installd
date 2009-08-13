class AddColumnsToInstallsAndApps < ActiveRecord::Migration
  
  def self.up
    add_column :apps, :artist_name, :string
    add_column :apps, :artist_id, :string
    add_column :apps, :genre, :string
    add_column :apps, :genre_id, :string
    
    add_column :installs, :price, :integer
    add_column :installs, :display_price, :string
    add_column :installs, :released_at, :datetime
    add_column :installs, :store_code, :string
    add_column :installs, :software_version_bundle_id, :string
    add_column :installs, :software_version_external_identifier, :string
    
    puts "Updating installs and apps from raw XML ..."
    
    Install.all.each do |install|
      parser = IphoneAppPlistParser.new(install.raw_xml)
      attributes = parser.attributes
      unless install.update_attributes(
          attributes.slice(
            :price,
            :display_price,
            :released_at,
            :store_code,
            :software_version_bundle_id,
            :software_version_external_identifier
          )
        )
        messsages = install.errors.full_messages.join(',')
        puts "*** Warning: Install #{install.id} not updated due to #{messsages}"
      end
      unless install.app.update_attributes(
          attributes.slice(
            :artist_name,
            :artist_id,
            :genre,
            :genre_id
          )
        )
        messsages = install.errors.full_messages.join(',')
        puts "*** Warning: App #{app.id} not updated due to #{messsages}"
      end
    end
    
    puts "... Done."
  end
  
  def self.down
    remove_column :apps, :artist_name
    remove_column :apps, :artist_id
    remove_column :apps, :genre
    remove_column :apps, :genre_id
    
    remove_column :installs, :price
    remove_column :installs, :display_price
    remove_column :installs, :released_at
    remove_column :installs, :store_code
    remove_column :installs, :software_version_bundle_id
    remove_column :installs, :software_version_external_identifier
  end
  
end
