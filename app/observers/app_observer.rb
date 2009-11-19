require 'action_controller/test_process'

class AppObserver < ActiveRecord::Observer
  
  observe :app
  
  def after_create(app)
    expire_cache_for(app)
  end
  
  def after_update(app)
    expire_cache_for(app)
  end
  
  def after_destroy(app)
    expire_cache_for(app)
  end
  
  private
  
  def expire_cache_for(record)
    base_path = ActionController::Caching::Actions::ActionCachePath.path_for(controller, { :controller => 'apps', :action => 'recent' }, false)
    controller.expire_fragment(Regexp.new("#{base_path}(|\.page\=\d+|\.rss)\.cache"))
  end
  
  def controller
    @controller ||= returning(ApplicationController.new) do |controller|
      request = ActionController::TestRequest.new
      request.host = HOST
      controller.request = request
      controller.params = {}
      controller.send(:initialize_current_url)
    end
  end
  
end
