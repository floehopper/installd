require 'activeresource'

module Remote
  
  class App < ActiveResource::Base
    
    self.site = "http://installd.com/"
    
    class << self
      
      def find_by_name(name)
        find(:first, :params => { :name => name })
      end
      
    end
    
  end

end