require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe NetworksController, 'show' do
  
  it 'should select apps installed by any users in the network' do
    app_1 = Factory(:app)
    user = Factory(:active_user)
    Factory(:event, :app => app_1, :user => user)
    
    app_2 = Factory(:app)
    network_user_1 = Factory(:active_user)
    Factory(:event, :app => app_2, :user => network_user_1)
    
    app_3 = Factory(:app)
    network_user_2 = Factory(:active_user)
    Factory(:event, :app => app_3, :user => network_user_2)
    
    user.connections.create!(:connected_user => network_user_1)
    user.connections.create!(:connected_user => network_user_2)
    
    get :show, :user_id => user.login
    
    apps = assigns[:apps]
    apps.size.should == 3
    apps.should include(app_1)
    apps.should include(app_2)
    apps.should include(app_3)
  end
   
  it 'should select apps installed by any users in the network without counting apps with updates twice' do
    app_1 = Factory(:app)
    user = Factory(:active_user)
    Factory(:event, :app => app_1, :user => user, :current => false)
    Factory(:event, :app => app_1, :user => user)
    
    app_2 = Factory(:app)
    network_user_1 = Factory(:active_user)
    Factory(:event, :app => app_2, :user => network_user_1, :current => false)
    Factory(:event, :app => app_2, :user => network_user_1)
    
    app_3 = Factory(:app)
    network_user_2 = Factory(:active_user)
    Factory(:event, :app => app_3, :user => network_user_2, :current => false)
    Factory(:event, :app => app_3, :user => network_user_2)
    
    user.connections.create!(:connected_user => network_user_1)
    user.connections.create!(:connected_user => network_user_2)
    
    get :show, :user_id => user.login
    
    apps = assigns[:apps]
    apps.size.should == 3
    apps.should include(app_1)
    apps.should include(app_2)
    apps.should include(app_3)
  end
   
  it 'should select apps installed by any users in the network without counting currently uninstalled apps' do
    app_1 = Factory(:app)
    user = Factory(:active_user)
    Factory(:event, :app => app_1, :user => user, :current => false)
    Factory(:event, :app => app_1, :user => user, :installed => false)
    
    app_2 = Factory(:app)
    network_user_1 = Factory(:active_user)
    Factory(:event, :app => app_2, :user => network_user_1, :current => false)
    Factory(:event, :app => app_2, :user => network_user_1, :installed => false)
    
    app_3 = Factory(:app)
    network_user_2 = Factory(:active_user)
    Factory(:event, :app => app_3, :user => network_user_2, :current => false)
    Factory(:event, :app => app_3, :user => network_user_2, :installed => false)
    
    user.connections.create!(:connected_user => network_user_1)
    user.connections.create!(:connected_user => network_user_2)
    
    get :show, :user_id => user.login
    
    apps = assigns[:apps]
    apps.size.should == 0
  end
   
  it 'should select apps installed by any users in the network without counting reinstalled apps twice' do
    app_1 = Factory(:app)
    user = Factory(:active_user)
    Factory(:event, :app => app_1, :user => user, :current => false)
    Factory(:event, :app => app_1, :user => user, :current => false, :installed => false)
    Factory(:event, :app => app_1, :user => user, :installed => true)
    
    app_2 = Factory(:app)
    network_user_1 = Factory(:active_user)
    Factory(:event, :app => app_2, :user => network_user_1, :current => false)
    Factory(:event, :app => app_2, :user => network_user_1, :current => false, :installed => false)
    Factory(:event, :app => app_2, :user => network_user_1, :installed => true)
    
    app_3 = Factory(:app)
    network_user_2 = Factory(:active_user)
    Factory(:event, :app => app_3, :user => network_user_2, :current => false)
    Factory(:event, :app => app_3, :user => network_user_2, :current => false, :installed => false)
    Factory(:event, :app => app_3, :user => network_user_2, :installed => true)
    
    user.connections.create!(:connected_user => network_user_1)
    user.connections.create!(:connected_user => network_user_2)
    
    get :show, :user_id => user.login
    
    apps = assigns[:apps]
    apps.size.should == 3
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
    Factory(:event, :app => app_1, :user => user)
    Factory(:event, :app => app_2, :user => user)
    
    network_user_1 = Factory(:active_user)
    Factory(:event, :app => app_1, :user => network_user_1)
    
    app_3 = Factory(:app)
    network_user_2 = Factory(:active_user)
    Factory(:event, :app => app_3, :user => network_user_2)
    
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
    Factory(:event, :app => app_1, :user => user)
    Factory(:event, :app => app_2, :user => user)
    
    network_user_1 = Factory(:active_user)
    Factory(:event, :app => app_1, :user => network_user_1)
    
    app_3 = Factory(:app)
    network_user_2 = Factory(:active_user)
    Factory(:event, :app => app_3, :user => network_user_2)
    
    user.connections.create!(:connected_user => network_user_1)
    user.connections.create!(:connected_user => network_user_2)
    
    get :not_in_common, :user_id => user.login
    
    apps = assigns[:apps]
    apps.should include(app_3)
    apps.should_not include(app_1)
    apps.should_not include(app_2)
  end
   
end
