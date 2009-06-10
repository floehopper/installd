ActionController::Routing::Routes.draw do |map|
  
  map.resources :users, :only => [:show, :new, :create]
  
  map.resource :user_session, :only => [:new, :create]
  
  map.root :controller => 'home'
  
end
