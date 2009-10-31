require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sync, 'validation' do
  
  before do
    @user = Factory.create(:user)
  end
  
  it 'should default status to nil to indicate sync has not yet parsed xml' do
    sync = @user.syncs.create!
    sync.status.should be_nil
  end
  
  it 'should be valid if there is no existing sync for this user' do
    sync = @user.syncs.build(Factory.attributes_for(:sync))
    sync.should be_valid
  end
  
  it 'should not be valid if last sync has not yet completed' do
    @user.syncs.create!(Factory.attributes_for(:sync))
    sync = @user.syncs.build(Factory.attributes_for(:sync))
    sync.should_not be_valid
  end
  
  it 'should be valid if last sync has completed successfully' do
    @user.syncs.create!(Factory.attributes_for(:sync, :status => 'success'))
    sync = @user.syncs.build(Factory.attributes_for(:sync))
    sync.should be_valid
  end
  
  it 'should be valid if last sync has failed' do
    @user.syncs.create!(Factory.attributes_for(:sync, :status => 'failure: StandardError'))
    sync = @user.syncs.build(Factory.attributes_for(:sync))
    sync.should be_valid
  end
  
  it 'should be able to update an existing sync even if it has not completed' do
    sync = @user.syncs.create!(Factory.attributes_for(:sync))
    sync.should be_valid
  end
  
end

describe Sync, 'behaviour' do
  
  before do
    @user = Factory.create(:user)
  end
  
  it 'should not propogate an exception because we do not want delayed_job to try to run it again' do
    sync = @user.syncs.create!(Factory.attributes_for(:sync))
    MultipleIphoneAppPlistParser.stub!(:new).and_raise(StandardError)
    
    lambda { sync.parse }.should_not raise_error
  end
  
  it 'should update status if an exception is raised so that another sync can be created' do
    sync = @user.syncs.create!(Factory.attributes_for(:sync))
    MultipleIphoneAppPlistParser.stub!(:new).and_raise(StandardError)
    
    sync.parse
    
    sync.reload
    sync.status.should == 'failure: StandardError'
  end
  
  it 'should successfully parse empty xml and update sync status' do
    sync = @user.syncs.create!(Factory.attributes_for(:sync, :raw_xml => ''))
    
    lambda { sync.parse }.should_not raise_error
    
    sync.reload
    sync.status.should == 'success'
  end
  
end