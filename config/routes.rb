ActionController::Routing::Routes.draw do |map|
  
  map.resources :users, :only => [:show]
  
  map.resource :user_session, :only => [:create]
  
  map.root :controller => 'home'
  
end
