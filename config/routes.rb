ActionController::Routing::Routes.draw do |map|
  
  map.resources :users, :only => [:show, :new, :create] do |users|
    users.resources :friendships, :only => [:new, :create]
    users.resources :installs, :only => [:index]
    users.resources :friends_installs, :only => [:index]
  end
  
  map.resource :user_session, :only => [:new, :create]
  
  map.root :controller => 'home'
  
end
