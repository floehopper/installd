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
    
    assert_difference('App.count', 1) do
      @user.synchronize([app_attributes.merge(event_attributes)], sync)
    end
    
    app = App.first
    App.extract_attributes(app.attributes).should == app_attributes
  end
  
  it 'should not create app if app already exists' do
    app_attributes = Factory.attributes_for(:app, :name => 'does-exist')
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    sync_0 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_0)
    
    sync_1 = Factory(:sync, :user => @user)
    
    assert_difference('App.count', 0) do
      @user.synchronize([app_attributes.merge(event_attributes)], sync_1)
    end
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
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.synchronize([app_attributes.merge(event_attributes)], sync)
    end
    
    assert_only_last_event_is_current(@user.events)
    event = @user.events.first
    event.state.should == 'Initial'
    Event.extract_attributes(event.attributes).should == event_attributes
  end
  
  it 'should not create event if user installed app, synced, and synced again' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    sync_0 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_0)
    
    sync_1 = Factory(:sync, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 0) do
      @user.synchronize([app_attributes.merge(event_attributes)], sync_1)
    end
  end
  
  it 'should create event if user installed app, synced, updated app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>original</xml>')
    
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_0)
    
    new_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>changed</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.synchronize([app_attributes.merge(new_event_attributes)], sync_1)
    end
    
    assert_only_last_event_is_current(@user.events)
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
    @user.synchronize([app_attributes.merge(event_attributes)], sync_0)
    
    new_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>changed</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(new_event_attributes)], sync_1)
    
    another_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>original</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    sync_2 = Factory(:sync, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.synchronize([app_attributes.merge(another_event_attributes)], sync_2)
    end
    
    assert_only_last_event_is_current(@user.events)
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
    @user.synchronize([app_attributes.merge(event_attributes)], sync_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.synchronize([], sync_1)
    end
    
    assert_only_last_event_is_current(@user.events)
    uninstall_event = @user.events.last
    uninstall_event.state.should == 'Uninstall'
    Event.extract_attributes(uninstall_event.attributes).should == event_attributes
  end
  
  it 'should create event if user installed app, synced, uninstalled app, synced, re-installed app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([], sync_1)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    sync_2 = Factory(:sync, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.synchronize([app_attributes.merge(event_attributes)], sync_2)
    end
    
    assert_only_last_event_is_current(@user.events)
    reinstall_event = @user.events.last
    reinstall_event.state.should == 'Install'
    Event.extract_attributes(reinstall_event.attributes).should == event_attributes
  end
  
  it 'should not create uninstall event if user installed app, synced, uninstalled app, synced, and then synced again' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([], sync_1)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    sync_2 = Factory(:sync, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 0) do
      @user.synchronize([], sync_2)
    end
    
    assert_only_last_event_is_current(@user.events)
    uninstall_event = @user.events.last
    uninstall_event.state.should == 'Uninstall'
    Event.extract_attributes(uninstall_event.attributes).should == event_attributes
  end
  
  def assert_only_last_event_is_current(events)
    other_events = events.dup
    last_event = other_events.pop
    other_events.any? { |e| e.current? }.should be_false
    last_event.should be_current
  end
  
end