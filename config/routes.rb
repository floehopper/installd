ActionController::Routing::Routes.draw do |map|
  
  map.resources :users, :only => [:show, :new, :create] do |users|
    users.resources :connections, :only => [:new, :create]
    users.resources :installs, :only => [:index], :collection => { :synchronize => :put }
    users.resource :network, :only => [:show], :member => { :in_common => :get, :not_in_common => :get }
  end
  
  map.resources :activations, :only => [:new, :create]
  
  map.resources :downloads, :only => [:index]
  
  map.resource :user_session, :only => [:new, :create, :destroy], :member => { :delete => :get }
  
  map.recent '/recent', :controller => 'installs', :action => 'recent'
  map.popular '/popular', :controller => 'installs', :action => 'popular'
  
  map.about '/about', :controller => 'pages', :action => 'about'
  map.privacy '/privacy', :controller => 'pages', :action => 'privacy'
  
  map.root :controller => 'home'
  
end
