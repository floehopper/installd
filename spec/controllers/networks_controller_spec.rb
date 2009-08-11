require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe NetworksController, 'show' do
  
  it 'should select apps installed by all users in the network' do
    app_1 = Factory(:app)
    user = Factory(:active_user)
    user.installs.create!(:app => app_1)
    
    app_2 = Factory(:app)
    network_user_1 = Factory(:active_user)
    network_user_1.installs.create!(:app => app_2)
    
    app_3 = Factory(:app)
    network_user_2 = Factory(:active_user)
    network_user_2.installs.create!(:app => app_3)
    
    user.connections.create!(:connected_user => network_user_1)
    user.connections.create!(:connected_user => network_user_2)
    
    get :show, :user_id => user.login
    
    apps = assigns[:apps]
    apps.should include(app_1)
    apps.should include(app_2)
    apps.should include(app_3)
  end
   
end

describe NetworksController, 'in_common' do
  
  it 'should select apps installed by other user(s) in the network that user has installed' do
    app_1 = Factory(:app)
    app_2 = Factory(:app)
    user = Factory(:active_user)
    user.installs.create!(:app => app_1)
    user.installs.create!(:app => app_2)
    
    network_user_1 = Factory(:active_user)
    network_user_1.installs.create!(:app => app_1)
    
    app_3 = Factory(:app)
    network_user_2 = Factory(:active_user)
    network_user_2.installs.create!(:app => app_3)
    
    user.connections.create!(:connected_user => network_user_1)
    user.connections.create!(:connected_user => network_user_2)
    
    get :in_common, :user_id => user.login
    
    apps = assigns[:apps]
    apps.should include(app_1)
    apps.should_not include(app_2)
    apps.should_not include(app_3)
  end
   
end

describe NetworksController, 'not_in_common' do
  
  it 'should select apps installed by other user(s) in the network that user does not have installed' do
    app_1 = Factory(:app)
    app_2 = Factory(:app)
    user = Factory(:active_user)
    user.installs.create!(:app => app_1)
    user.installs.create!(:app => app_2)
    
    network_user_1 = Factory(:active_user)
    network_user_1.installs.create!(:app => app_1)
    
    app_3 = Factory(:app)
    network_user_2 = Factory(:active_user)
    network_user_2.installs.create!(:app => app_3)
    
    user.connections.create!(:connected_user => network_user_1)
    user.connections.create!(:connected_user => network_user_2)
    
    get :not_in_common, :user_id => user.login
    
    apps = assigns[:apps]
    apps.should include(app_3)
    apps.should_not include(app_1)
    apps.should_not include(app_2)
  end
   
end
