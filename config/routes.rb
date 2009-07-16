ActionController::Routing::Routes.draw do |map|
  
  map.resources :users, :only => [:show, :new, :create] do |users|
    users.resources :connections, :only => [:new, :create]
    users.resources :installs, :only => [:index], :collection => { :synchronize => :put }
    users.resource :network, :only => [:show], :member => { :in_common => :get, :not_in_common => :get }
  end
  
  map.resources :activations, :only => [:new, :create]
  
  map.resources :downloads, :only => [:index]
  
  map.resource :user_session, :only => [:new, :create, :destroy], :member => { :delete => :get }
  
  map.root :controller => 'installs'
  
end
