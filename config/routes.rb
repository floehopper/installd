ActionController::Routing::Routes.draw do |map|
  map.resource :account, :controller => "users"
  map.resources :users, :has_many => :apps
  map.resource :user_session, :only => [:new, :create, :destroy], :member => { :delete => :get }
  map.root :controller => "user_sessions", :action => "new"
end
