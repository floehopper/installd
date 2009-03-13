require 'activeresource'

module Remote
  
  class App < ActiveResource::Base
    
    self.site = "http://localhost:3000/"
    
    class << self
      
      def find_by_name(name)
        find(:first, :params => { :name => name })
      end
      
    end
    
  end

end