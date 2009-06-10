ActionController::Routing::Routes.draw do |map|
  
  map.resources :users, :only => [:show]
  
end
