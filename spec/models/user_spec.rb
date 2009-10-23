require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User, 'sync apps' do
  
  before do
    @user = Factory(:active_user)
    @syncs = Array.new(2) { Factory(:sync, :user => @user) }
  end
  
  it 'should create app if app does not exist' do
    app_attributes = Factory.attributes_for(:app, :name => 'does-not-exist')
    install_attributes = Factory.attributes_for(:install_from_xml)
    
    sync = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(install_attributes)], sync)
    
    app = App.first
    app.should_not be_nil
    App.extract_attributes(app.attributes).should == app_attributes
  end
  
  it 'should not create app if app already exists' do
    app_attributes = Factory.attributes_for(:app, :name => 'does-exist')
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    sync_0 = Factory(:sync, :user => @user)
    @user.installs.create!(install_attributes.merge(:state => 'Initial', :app => app, :sync => sync_0))
    
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(install_attributes)], sync_1)
    
    App.all.should == [app]
  end
  
end

describe User, 'sync installs' do
  
  before do
    @user = Factory(:active_user)
  end
  
  it 'should create install if user installed app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    sync = Factory(:sync, :user => @user)
    
    @user.synchronize([app_attributes.merge(install_attributes)], sync)
    
    @user.installs.size.should == 1
    install = @user.installs.first
    install.should_not be_nil
    install.state.should == 'Initial'
    Install.extract_attributes(install.attributes).should == install_attributes
  end
  
  it 'should not create install if user installed app, synced, and synced again' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    sync_0 = Factory(:sync, :user => @user)
    install = @user.installs.create!(install_attributes.merge(:state => 'Initial', :app => app, :sync => sync_0))
    
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(install_attributes)], sync_1)
    
    @user.installs.should == [install]
  end
  
  it 'should create install if user installed app, synced, updated app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml, :raw_xml => '<xml>original</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    install = @user.installs.create!(install_attributes.merge(:state => 'Initial', :app => app, :sync => sync_0))
    new_install_attributes = Factory.attributes_for(:install_from_xml, :raw_xml => '<xml>changed</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(new_install_attributes)], sync_1)
    
    @user.installs.length.should == 2
    new_install = @user.installs.last
    new_install.state.should == 'Update'
    Install.extract_attributes(new_install.attributes).should == new_install_attributes
  end
  
  it 'should create install if user installed app, synced, updated app, synced, updated app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml, :raw_xml => '<xml>original</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    install = @user.installs.create!(install_attributes.merge(:state => 'Initial', :app => app, :sync => sync_0))
    new_install_attributes = Factory.attributes_for(:install_from_xml, :raw_xml => '<xml>changed</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    new_install = @user.installs.create!(new_install_attributes.merge(:state => 'Updated', :app => app, :sync => sync_1))
    another_install_attributes = Factory.attributes_for(:install_from_xml, :raw_xml => '<xml>original</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    
    sync_2 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(another_install_attributes)], sync_2)
    
    @user.installs.length.should == 3
    another_install = @user.installs.last
    another_install.state.should == 'Update'
    Install.extract_attributes(another_install.attributes).should == another_install_attributes
  end
  
  it 'should create uninstall if user installed app, synced, uninstalled app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    install = @user.installs.create!(install_attributes.merge(:state => 'Initial', :app => app, :sync => sync_0))
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    
    sync_1 = Factory(:sync, :user => @user)
    @user.synchronize([], sync_1)
    
    @user.installs.length.should == 2
    uninstall = @user.installs.last
    uninstall.installed.should == false
    uninstall.state.should == 'Uninstall'
    Install.extract_attributes(uninstall.attributes).should == install_attributes
  end
  
  it 'should create install if user installed app, synced, uninstalled app, synced, re-installed app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    install = @user.installs.create!(install_attributes.merge(:state => 'Initial', :app => app, :sync => sync_0))
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    uninstall = @user.installs.create!(install_attributes.merge(:state => 'Uninstall', :installed => false, :app => app, :sync => sync_1))
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    
    sync_2 = Factory(:sync, :user => @user)
    @user.synchronize([app_attributes.merge(install_attributes)], sync_2)
    
    @user.installs.length.should == 3
    reinstall = @user.installs.last
    reinstall.installed.should == true
    reinstall.state.should == 'Install'
    Install.extract_attributes(reinstall.attributes).should == install_attributes
  end
  
  it 'should not create uninstall if user installed app, synced, uninstalled app, synced, and then synced again' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    sync_0 = Factory(:sync, :user => @user)
    install = @user.installs.create!(install_attributes.merge(:state => 'Initial', :app => app, :sync => sync_0))
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    sync_1 = Factory(:sync, :user => @user)
    uninstall = @user.installs.create!(install_attributes.merge(:state => 'Uninstall', :installed => false, :app => app, :sync => sync_1))
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    
    sync_2 = Factory(:sync, :user => @user)
    @user.synchronize([], sync_2)
    
    @user.installs.length.should == 2
    uninstall = @user.installs.last
    uninstall.installed.should == false
    uninstall.state.should == 'Uninstall'
    Install.extract_attributes(uninstall.attributes).should == install_attributes
  end
  
end