require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User, 'sync apps' do
  
  before do
    @user = Factory(:active_user)
    @sync_sessions = Array.new(2) { Factory(:successful_sync_session, :user => @user) }
  end
  
  it 'should create app if app does not exist' do
    app_attributes = Factory.attributes_for(:app, :name => 'does-not-exist')
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    sync_session = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('App.count', 1) do
      @user.synchronize([app_attributes.merge(event_attributes)], sync_session)
    end
    
    app = App.first
    App.extract_attributes(app.attributes).should == app_attributes
  end
  
  it 'should not create app if app already exists' do
    app_attributes = Factory.attributes_for(:app, :name => 'does-exist')
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('App.count', 0) do
      @user.synchronize([app_attributes.merge(event_attributes)], sync_session_1)
    end
  end
  
end

describe User, 'sync events' do
  
  before do
    @user = Factory(:active_user)
  end
  
  it 'should create initial event if user installed app, and synced for the first time' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    sync_session = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.synchronize([app_attributes.merge(event_attributes)], sync_session)
    end
    
    assert_only_last_event_is_current(@user.events)
    event = @user.events.first
    event.state.should == 'Initial'
    Event.extract_attributes(event.attributes).should == event_attributes
  end
  
  it 'should create install event if user synced, installed app, and synced again' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([], sync_session_0)
    
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_1)
    
    assert_only_last_event_is_current(@user.events)
    event = @user.events.first
    event.state.should == 'Install'
    Event.extract_attributes(event.attributes).should == event_attributes
  end
  
  it 'should not create event if user installed app, synced, and synced again' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 0) do
      @user.synchronize([app_attributes.merge(event_attributes)], sync_session_1)
    end
  end
  
  it 'should create event if user installed app, synced, updated app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>original</xml>', :purchased_at => Time.now)
    
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    new_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>changed</xml>', :purchased_at => Time.now)
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.synchronize([app_attributes.merge(new_event_attributes)], sync_session_1)
    end
    
    assert_only_last_event_is_current(@user.events)
    new_event = @user.events.last
    new_event.state.should == 'Update'
    Event.extract_attributes(new_event.attributes).should == new_event_attributes
  end
  
  it 'should not create event if user installed app, synced, changed app (earlier purchase date), and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>original</xml>', :purchased_at => Time.parse('2009-01-02'))
    
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    new_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>changed</xml>', :purchased_at => Time.parse('2009-01-01'))
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 0) do
      @user.synchronize([app_attributes.merge(new_event_attributes)], sync_session_1)
    end
  end
  
  it 'should create event if user installed app, synced, updated app, synced, updated app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>original</xml>', :purchased_at => Time.now)
    
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    new_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>changed</xml>', :purchased_at => Time.now)
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(new_event_attributes)], sync_session_1)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    another_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>original</xml>', :purchased_at => Time.now)
    sync_session_2 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.synchronize([app_attributes.merge(another_event_attributes)], sync_session_2)
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
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.synchronize([], sync_session_1)
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
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([], sync_session_1)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    sync_session_2 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.synchronize([app_attributes.merge(event_attributes)], sync_session_2)
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
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([], sync_session_1)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    sync_session_2 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 0) do
      @user.synchronize([], sync_session_2)
    end
    
    assert_only_last_event_is_current(@user.events)
    uninstall_event = @user.events.last
    uninstall_event.state.should == 'Uninstall'
    Event.extract_attributes(uninstall_event.attributes).should == event_attributes
  end
  
  it 'should create event if user installed app, synced, and manually uninstalled app' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 1) do
      @user.create_manual_uninstall!(app, sync_session_1)
    end
    
    assert_only_last_event_is_current(@user.events)
    manual_uninstall_event = @user.events.last
    manual_uninstall_event.state.should == 'Ignore'
    Event.extract_attributes(manual_uninstall_event.attributes).should == event_attributes
  end
  
  it 'should not create event if user installed app, synced, uninstalled app, synced, and manually uninstalled app' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([], sync_session_1)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    sync_session_2 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 0) do
      @user.create_manual_uninstall!(app, sync_session_2)
    end
    
    assert_only_last_event_is_current(@user.events)
    uninstall_event = @user.events.last
    uninstall_event.state.should == 'Uninstall'
    Event.extract_attributes(uninstall_event.attributes).should == event_attributes
  end
  
  it 'should not create event if user installed app, synced, manually uninstalled app, uninstalled app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    event_attributes = Factory.attributes_for(:event_from_xml)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    @user.create_manual_uninstall!(app, sync_session_1)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    sync_session_2 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 0) do
      @user.synchronize([], sync_session_2)
    end
    
    assert_only_last_event_is_current(@user.events)
    manual_uninstall_event = @user.events.last
    manual_uninstall_event.state.should == 'Ignore'
    Event.extract_attributes(manual_uninstall_event.attributes).should == event_attributes
  end
  
  it 'should not create event if user installed app, synced, manually uninstalled app, updated app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>original</xml>', :purchased_at => Time.now)
    
    sync_session_0 = Factory(:successful_sync_session, :user => @user)
    @user.synchronize([app_attributes.merge(event_attributes)], sync_session_0)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_session_1 = Factory(:successful_sync_session, :user => @user)
    @user.create_manual_uninstall!(app, sync_session_1)
    
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    new_event_attributes = Factory.attributes_for(:event_from_xml, :raw_xml => '<xml>changed</xml>', :purchased_at => Time.now)
    sync_session_2 = Factory(:successful_sync_session, :user => @user)
    
    assert_difference('@user.events(reload = true).size', 0) do
      @user.synchronize([app_attributes.merge(new_event_attributes)], sync_session_2)
    end
    
    assert_only_last_event_is_current(@user.events)
    manual_uninstall_event = @user.events.last
    manual_uninstall_event.state.should == 'Ignore'
    Event.extract_attributes(manual_uninstall_event.attributes).should == event_attributes
  end
  
  def assert_only_last_event_is_current(events)
    other_events = events.dup
    last_event = other_events.pop
    other_events.any? { |e| e.current? }.should be_false
    last_event.should be_current
  end
  
end