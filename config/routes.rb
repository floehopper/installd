ActionController::Routing::Routes.draw do |map|

  map.resources :apps
  
  map.resource :account, :controller => "users"
  map.resource :user_session, :only => [:new, :create, :destroy], :member => { :delete => :get }
  
  map.root :controller => "user_sessions", :action => "new"
  
end
