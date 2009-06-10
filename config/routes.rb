ActionController::Routing::Routes.draw do |map|

  map.resources :users, :has_many => [:installs, :apps], :shallow => true
  map.resources :installs
  map.resources :apps
  
  map.resource :account, :controller => 'users'
  
  map.resource :user_session, :only => [:new, :create, :destroy], :member => { :delete => :get }
  
  map.root :controller => 'user_sessions', :action => 'new'
  
end
