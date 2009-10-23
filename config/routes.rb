ActionController::Routing::Routes.draw do |map|
  
  map.resources :users, :only => [:index, :show, :new, :create], :member => { :invite => :put } do |users|
    users.resources :connections, :only => [:new, :create, :destroy], :member => { :delete => :get }
    users.resources :installs, :only => [:index, :update], :collection => { :synchronize => :put }, :shallow => true
    users.resource :network, :only => [:show], :member => { :in_common => :get, :not_in_common => :get }
  end
  
  map.resources :apps, :only => [:show]
  
  map.resources :activations, :only => [:new, :create]
  
  map.resources :downloads, :only => [:index], :collection => { :mac => :get, :linux => :get, :windows => :get }
  
  map.resource :user_session, :only => [:new, :create, :destroy], :member => { :delete => :get }
  
  map.recent '/recent', :controller => 'apps', :action => 'recent'
  map.popular '/popular', :controller => 'apps', :action => 'popular'
  map.rated '/rated', :controller => 'apps', :action => 'rated'
  map.lookup_user '/lookup_user', :controller => 'users', :action => 'lookup'
  
  map.about '/about', :controller => 'pages', :action => 'about'
  map.privacy '/privacy', :controller => 'pages', :action => 'privacy'
  
  map.root :controller => 'apps', :action => 'recent'
  
end
