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
    },
    :collection => {
      :lookup => :get
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
      users.resources :events,
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
  map.resources :events,
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
  
  map.about '/about', :controller => 'pages', :action => 'about'
  map.privacy '/privacy', :controller => 'pages', :action => 'privacy'
  map.downloads '/downloads', :controller => 'downloads', :action => 'index'
  
  # legacy route for client versions <= 0.0.5
  map.connect '/users/:user_id/installs/synchronize', :controller => 'events', :action => 'synchronize'
  
  map.root :controller => 'apps', :action => 'summary'
  
end
