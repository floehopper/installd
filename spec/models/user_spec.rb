require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User, 'sync apps' do
  
  before do
    @user = Factory(:active_user)
    @syncs = Array.new(2) { Factory(:sync, :user => @user) }
  end
  
  it 'should create app if app does not exist' do
    app_attributes = Factory.attributes_for(:app, :name => 'does-not-exist')
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    sync = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync)
    
    app = App.first
    app.should_not be_nil
    App.extract_attributes(app.attributes).should == app_attributes
  end
  
  it 'should not create app if app already exists' do
    app_attributes = Factory.attributes_for(:app, :name => 'does-exist')
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    sync_0 = Factory(:sync, :user => @user)
    @user.events.create!(event_attributes.merge(:current => true, :state => 'Initial', :app => app, :sync => sync_0))
    
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_1)
    
    App.all.should == [app]
  end
  
end

describe User, 'sync events' do
  
  before do
    @user = Factory(:active_user)
  end
  
  it 'should create event if user installed app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    sync = Factory(:sync, :user => @user)
    
    @user.synchronize([app_attributes.merge(event_attributes)], sync)
    
    @user.events.size.should == 1
    @user.events(reload = true).map(&:current).should == [true]
    event = @user.events.first
    event.should_not be_nil
    event.state.should == 'Initial'
    Event.extract_attributes(event.attributes).should == event_attributes
  end
  
  it 'should not create event if user installed app, synced, and synced again' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    sync_0 = Factory(:sync, :user => @user)
    event = @user.events.create!(event_attributes.merge(:current => true, :state => 'Initial', :app => app, :sync => sync_0))
    
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_1)
    
    @user.events.should == [event]
    @user.events(reload = true).map(&:current).should == [true]
  end
  
  it 'should create event if user installed app, synced, updated app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>original</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    event = @user.events.create!(event_attributes.merge(:current => true, :state => 'Initial', :app => app, :sync => sync_0))
    new_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>changed</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(new_event_attributes)], sync_1)
    
    @user.events.length.should == 2
    @user.events(reload = true).map(&:current).should == [false, true]
    new_event = @user.events.last
    new_event.state.should == 'Update'
    Event.extract_attributes(new_event.attributes).should == new_event_attributes
  end
  
  it 'should create event if user installed app, synced, updated app, synced, updated app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>original</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    event = @user.events.create!(event_attributes.merge(:current => false, :state => 'Initial', :app => app, :sync => sync_0))
    new_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>changed</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    new_event = @user.events.create!(new_event_attributes.merge(:current => true, :state => 'Updated', :app => app, :sync => sync_1))
    another_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>original</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    
    sync_2 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(another_event_attributes)], sync_2)
    
    @user.events.length.should == 3
    @user.events(reload = true).map(&:current).should == [false, false, true]
    another_event = @user.events.last
    another_event.state.should == 'Update'
    Event.extract_attributes(another_event.attributes).should == another_event_attributes
  end
  
  it 'should create uninstall event if user installed app, synced, uninstalled app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    event = @user.events.create!(event_attributes.merge(:current => true, :state => 'Initial', :app => app, :sync => sync_0))
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([], sync_1)
    
    @user.events.length.should == 2
    @user.events(reload = true).map(&:current).should == [false, true]
    uninstall_event = @user.events.last
    uninstall_event.installed.should == false
    uninstall_event.state.should == 'Uninstall'
    Event.extract_attributes(uninstall_event.attributes).should == event_attributes
  end
  
  it 'should create event if user installed app, synced, uninstalled app, synced, re-installed app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    event = @user.events.create!(event_attributes.merge(:current => false, :state => 'Initial', :app => app, :sync => sync_0))
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    uninstall_event = @user.events.create!(event_attributes.merge(:current => true, :state => 'Uninstall', :installed => false, :app => app, :sync => sync_1))
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    
    sync_2 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_2)
    
    @user.events.length.should == 3
    @user.events(reload = true).map(&:current).should == [false, false, true]
    reinstall_event = @user.events.last
    reinstall_event.installed.should == true
    reinstall_event.state.should == 'Install'
    Event.extract_attributes(reinstall_event.attributes).should == event_attributes
  end
  
  it 'should not create uninstall event if user installed app, synced, uninstalled app, synced, and then synced again' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    event = @user.events.create!(event_attributes.merge(:current => false, :state => 'Initial', :app => app, :sync => sync_0))
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    uninstall_event = @user.events.create!(event_attributes.merge(:current => true, :state => 'Uninstall', :installed => false, :app => app, :sync => sync_1))
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    
    sync_2 = Factory(:sync, :user => @user)
    @user.synchronize([], sync_2)
    
    @user.events.length.should == 2
    @user.events(reload = true).map(&:current).should == [false, true]
    uninstall_event = @user.events.last
    uninstall_event.installed.should == false
    uninstall_event.state.should == 'Uninstall'
    Event.extract_attributes(uninstall_event.attributes).should == event_attributes
  end
  
end