require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SyncSession, 'validation' do
  
  before do
    @user = Factory.create(:user)
  end
  
  it 'should default status to nil to indicate sync_session has not yet parsed xml' do
    sync_session = @user.sync_sessions.create!
    sync_session.status.should be_nil
  end
  
  it 'should be valid if there is no existing sync_session for this user' do
    sync_session = @user.sync_sessions.build(Factory.attributes_for(:sync_session))
    sync_session.should be_valid
  end
  
  it 'should not be valid if last sync_session has not yet completed' do
    @user.sync_sessions.create!(Factory.attributes_for(:sync_session))
    sync_session = @user.sync_sessions.build(Factory.attributes_for(:sync_session))
    sync_session.should_not be_valid
    sync_session.errors[:base].should == 'Previous sync session not yet complete'
  end
  
  it 'should be valid if last sync_session has completed successfully' do
    @user.sync_sessions.create!(Factory.attributes_for(:sync_session, :status => 'success'))
    sync_session = @user.sync_sessions.build(Factory.attributes_for(:sync_session))
    sync_session.should be_valid
  end
  
  it 'should be valid if last sync_session has failed' do
    @user.sync_sessions.create!(Factory.attributes_for(:sync_session, :status => 'failure: StandardError'))
    sync_session = @user.sync_sessions.build(Factory.attributes_for(:sync_session))
    sync_session.should be_valid
  end
  
  it 'should be able to update an existing sync_session even if it has not completed' do
    sync_session = @user.sync_sessions.create!(Factory.attributes_for(:sync_session))
    sync_session.should be_valid
  end
  
end

describe Sync, 'behaviour' do
  
  before do
    @user = Factory.create(:user)
  end
  
  it 'should not propogate an exception because we do not want delayed_job to try to run it again' do
    sync_session = @user.sync_sessions.create!(Factory.attributes_for(:sync_session))
    MultipleIphoneAppPlistParser.stub!(:new).and_raise(StandardError)
    
    lambda { sync_session.parse }.should_not raise_error
  end
  
  it 'should update status if an exception is raised so that another sync_session can be created' do
    sync_session = @user.sync_sessions.create!(Factory.attributes_for(:sync_session))
    MultipleIphoneAppPlistParser.stub!(:new).and_raise(StandardError)
    
    sync_session.parse
    
    sync_session.reload
    sync_session.status.should == 'failure: StandardError'
  end
  
  it 'should successfully parse empty xml and update sync_session status' do
    sync_session = @user.sync_sessions.create!(Factory.attributes_for(:sync_session, :raw_xml => ''))
    
    lambda { sync_session.parse }.should_not raise_error
    
    sync_session.reload
    sync_session.status.should == 'success'
  end
  
end