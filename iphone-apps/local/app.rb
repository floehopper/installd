require 'fileutils'
require 'hpricot'

module Local
  
  class App
    
    attr_reader :attributes
    
    def initialize(attributes = {})
      @attributes = attributes
    end
    
    def [](key)
      @attributes[key]
    end
    
    def self.all_by_name
      # maybe use a tmp directory instead?
      FileUtils.rm_rf('unzipped')
      FileUtils.mkdir_p('unzipped')
      
      apps_pattern = File.join(ENV['HOME'], 'Music', 'iTunes', 'Mobile Applications', '*.ipa')
      
      app_names = {}
      Dir[apps_pattern].each do |app_file|
        app_name = File.basename(app_file, '.ipa')
        unzip_dir = File.join('unzipped', app_name)
        plist = File.join(unzip_dir, 'iTunesMetadata.plist')
        
        # maybe do this in Ruby?
        `unzip -d "#{unzip_dir}" "#{app_file}" iTunesMetadata.plist`
        `plutil -convert xml1 "#{plist}"`
        
        doc = Hpricot(File.read(plist))
        (doc/'plist'/'dict'/'key').each do |element|
          if element.innerText == 'itemName'
            name = element.next_sibling.inner_text
            app_names[name] = new('name' => name)
            break
          end
        end
      end
      
      FileUtils.rm_rf('unzipped')
      app_names
    end
    
  end
  
end