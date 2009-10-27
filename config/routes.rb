ActionController::Routing::Routes.draw do |map|
  
  map.resources :users,
    :only => [
      :index,
      :show,
      :new,
      :create
    ],
    :member => {
      :invite => :put
    } do |users|
      users.resources :connections,
        :only => [
          :new,
          :create,
          :destroy
        ],
        :member => {
          :delete => :get
        }
      users.resources :installs,
        :only => [
          :index
        ],
        :collection => {
          :synchronize => :put
        }
      users.resource :network,
        :only => [
          :show
        ],
        :member => {
          :in_common => :get,
          :not_in_common => :get
        }
  end
  
  map.resources :apps,
    :only => [
      :show
    ],
    :collection => {
      :recent => :get,
      :popular => :get,
      :rated => :get
    }
  map.resources :installs,
    :only => [
      :index,
      :update
    ]
  map.resources :activations,
    :only => [
      :new,
      :create
    ]
  map.resource :user_session,
    :only => [
      :new,
      :create,
      :destroy
    ],
    :member => {
      :delete => :get
    }
  
  map.lookup_user '/lookup_user', :controller => 'users', :action => 'lookup'
  
  map.about '/about', :controller => 'pages', :action => 'about'
  map.privacy '/privacy', :controller => 'pages', :action => 'privacy'
  map.downloads '/downloads', :controller => 'downloads', :action => 'index'
  
  map.root :controller => 'apps', :action => 'recent'
  
end
