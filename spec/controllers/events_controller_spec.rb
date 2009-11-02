require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe EventsController, 'synchronize' do
  
  it 'should redirect to ssl if not requested via ssl' do
    put :synchronize, :user_id => 'login'
    
    expected_url = synchronize_user_events_url(:protocol => 'https', :user_id => 'login')
    response.should redirect_to(expected_url)
  end
  
  it 'should return not found status if user does not exist' do
    put_via_ssl :synchronize, :user_id => 'does-not-exist'
    
    response.status.should == '404 Not Found'
  end
  
  it 'should return forbidden status if user does exist, but user not logged in' do
    user = Factory.create(:active_user)
    not_logged_in
    
    put_via_ssl :synchronize, :user_id => user.login
    
    response.status.should == '403 Forbidden'
  end
  
  it 'should create sync session with forbidden status if user does exist, but user not logged in' do
    user = Factory.create(:active_user)
    not_logged_in
    
    put_via_ssl :synchronize, :user_id => user.login
    
    user.sync_sessions.size.should == 1
    user.sync_sessions.first.status.should == 'forbidden'
  end
  
  it 'should return forbidden status if user does exist, but user is logged in as a different user' do
    user_1 = Factory.create(:active_user)
    user_2 = Factory.create(:active_user)
    logged_in_as(user_1)
    
    put_via_ssl :synchronize, :user_id => user_2.login
    
    response.status.should == '403 Forbidden'
  end
  
  it 'should save exception in sync session and raise exception if exception occurs' do
    user = Factory.create(:active_user)
    logged_in_as(user)
    @controller.stub!(:current_user).and_raise(StandardError)
    
    lambda { put_via_ssl :synchronize, :user_id => user.login }.should raise_error
    
    user.sync_sessions.size.should == 1
    user.sync_sessions.first.status.should == 'exception: StandardError'
  end
  
  it 'should return success status if user does exist and user is logged in' do
    user = Factory.create(:active_user)
    logged_in_as(user)
    
    put_via_ssl :synchronize, :user_id => user.login
    
    response.should be_success
  end
  
  it 'should sync session with blank status if user does exist and user is logged in' do
    user = Factory.create(:active_user)
    logged_in_as(user)
    
    put_via_ssl :synchronize, :user_id => user.login, :doc => '<xml></xml>'
    
    user.sync_sessions.size.should == 1
    user.sync_sessions.first.status.should be_blank
  end
  
  it 'should create delayed job if user does exist and user is logged in' do
    user = Factory.create(:active_user)
    logged_in_as(user)
    
    assert_difference('Delayed::Job.count', 1) do
      put_via_ssl :synchronize, :user_id => user.login, :doc => '<xml></xml>'
    end
    
    job = Delayed::Job.first
    job.payload_object.display_name.should == 'SyncSession#parse'
  end
end
