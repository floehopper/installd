require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event, 'named scopes' do
  
  before do
    @user = Factory.create(:user)
  end
  
  it 'should consider initial events as installed' do
    event = Factory.create(:event, :state => 'Initial', :user => @user)
    @user.events.installed.should include(event)
  end
  
  it 'should consider install events as installed' do
    event = Factory.create(:event, :state => 'Install', :user => @user)
    @user.events.installed.should include(event)
  end
  
  it 'should consider update events as installed' do
    event = Factory.create(:event, :state => 'Update', :user => @user)
    @user.events.installed.should include(event)
  end
  
  it 'should consider uninstalled events as uninstalled' do
    event = Factory.create(:event, :state => 'Uninstall', :user => @user)
    @user.events.uninstalled.should include(event)
  end
  
  it 'should consider manually uninstalled events as uninstalled' do
    event = Factory.create(:event, :state => 'Ignore', :user => @user)
    @user.events.uninstalled.should include(event)
  end
  
end

describe Event, 'differs from' do
  
  it 'should be different if raw_xml hashcode is different' do
    event_1 = Factory.build(:event, :raw_xml => '<xml>original</xml>')
    event_2 = Factory.build(:event, :raw_xml => '<xml>changed</xml>')
    event_1.differs_from?(event_2).should be_true
  end
  
  it 'should not be different if raw_xml hashcode is same' do
    event_1 = Factory.build(:event, :raw_xml => '<xml>original</xml>')
    event_2 = Factory.build(:event, :raw_xml => '<xml>original</xml>')
    event_1.differs_from?(event_2).should be_false
  end
  
end
  
describe Event, 'purchased after' do
  
  it 'should be purchased after if purchased_at is later' do
    event_1 = Factory.build(:event, :purchased_at => Time.parse('2009-01-02'))
    event_2 = Factory.build(:event, :purchased_at => Time.parse('2009-01-01'))
    event_1.purchased_after?(event_2).should be_true
  end
  
  it 'should not be purchased after if purchased_at is earlier' do
    event_1 = Factory.build(:event, :purchased_at => Time.parse('2009-01-01'))
    event_2 = Factory.build(:event, :purchased_at => Time.parse('2009-01-02'))
    event_1.purchased_after?(event_2).should be_false
  end
  
  it 'should not be purchased after if purchased_at is the same' do
    event_1 = Factory.build(:event, :purchased_at => Time.parse('2009-01-01'))
    event_2 = Factory.build(:event, :purchased_at => Time.parse('2009-01-01'))
    event_1.purchased_after?(event_2).should be_false
  end
  
end
  
describe Event, 'update current' do
  
  before do
    @user = Factory.create(:user)
    @app = Factory.create(:app)
  end
  
  it 'should make new event current when first event for user and app' do
    different_app = Factory.create(:app)
    different_user = Factory.create(:user)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    Factory.create(:event, :user => @user, :app => different_app)
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    Factory.create(:event, :user => different_user, :app => @app)
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    Factory.create(:event, :user => @user, :app => @app)
    
    @user.events.last.should be_current
  end
  
  it 'should make new event current when not first event for user and app' do
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    Factory.create(:event, :user => @user, :app => @app)
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    Factory.create(:event, :user => @user, :app => @app)
    
    @user.events.last.should be_current
  end
  
  it 'should make previous event not current' do
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    Factory.create(:event, :user => @user, :app => @app)
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    Factory.create(:event, :user => @user, :app => @app)
    
    @user.events.first.should_not be_current
  end
  
end
