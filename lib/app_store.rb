module AppStore
  
  class << self
    
    UK_STORE_FRONT = '143444,5'
    
    def create_app(item_id)
      http = SimpleHttp.new(view_software_url(item_id))
      http.request_headers['User-Agent'] = 'iTunes/8.2.1 (Macintosh; U; PPC Mac OS X 10.5.8)'
      http.request_headers['X-Apple-Store-Front'] = UK_STORE_FRONT
      response = http.get
      App.new(response)
    end
    
    def view_software_url(item_id)
      "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=#{item_id}&mt=8"
    end
    
  end
  
  class App
    
    XPATH_TO_APPLICATION_DESCRIPTION = %w(
      Document
      View
      ScrollView
      VBoxView
      View
      MatrixView
      VBoxView
      View
      MatrixView
      VBoxView
      VBoxView
      TextView
    ).join('/')
    
    def initialize(response)
      @doc = Hpricot::XML(response)
    end
    
    def description
      text_views = (@doc/XPATH_TO_APPLICATION_DESCRIPTION)
      title = (text_views[0]/'SetFontStyle/b')[0].innerText
      raise unless title == 'APPLICATION DESCRIPTION'
      (text_views[1]/'SetFontStyle')[0].innerText
    rescue => e
      return nil
    end
    
  end
  
end

