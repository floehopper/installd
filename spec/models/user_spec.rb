require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User, 'sync apps' do
  
  before do
    @user = Factory(:active_user)
    @syncs = Array.new(2) { Factory(:sync, :user => @user) }
  end
  
  it 'should create app if app does not exist' do
    app_attributes = Factory.attributes_for(:app, :name => 'does-not-exist')
    install_attributes = Factory.attributes_for(:install_from_xml)
    
    @user.synchronize([app_attributes.merge(install_attributes)], @syncs[0])
    
    app = App.first
    app.should_not be_nil
    App.extract_attributes(app.attributes).should == app_attributes
  end
  
  it 'should not create app if app already exists' do
    app_attributes = Factory.attributes_for(:app, :name => 'does-exist')
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    @user.installs.create!(install_attributes.merge(:app => app, :sync => @syncs[0]))
    
    @user.synchronize([app_attributes.merge(install_attributes)], @syncs[1])
    
    App.all.should == [app]
  end
  
end

describe User, 'sync installs' do
  
  before do
    @user = Factory(:active_user)
    @syncs = Array.new(3) { Factory(:sync, :user => @user) }
  end
  
  it 'should create install if user installed app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    
    @user.synchronize([app_attributes.merge(install_attributes)], @syncs[0])
    
    install = @user.installs.first
    install.should_not be_nil
    Install.extract_attributes(install.attributes).should == install_attributes
  end
  
  it 'should not create install if user installed app, synced, and synced again' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    install = @user.installs.create!(install_attributes.merge(:app => app, :sync => @syncs[0]))
    
    @user.synchronize([app_attributes.merge(install_attributes)], @syncs[1])
    
    @user.installs.should == [install]
  end
  
  it 'should create install if user installed app, synced, updated app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml, :raw_xml => '<xml>original</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    install = @user.installs.create!(install_attributes.merge(:app => app, :sync => @syncs[0]))
    new_install_attributes = Factory.attributes_for(:install_from_xml, :raw_xml => '<xml>changed</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    
    @user.synchronize([app_attributes.merge(new_install_attributes)], @syncs[1])
    
    @user.installs.length.should == 2
    new_install = @user.installs.find(:last, :order => 'created_at')
    Install.extract_attributes(new_install.attributes).should == new_install_attributes
  end
  
  it 'should create install if user installed app, synced, updated app, synced, updated app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml, :raw_xml => '<xml>original</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    install = @user.installs.create!(install_attributes.merge(:app => app, :sync => @syncs[0]))
    new_install_attributes = Factory.attributes_for(:install_from_xml, :raw_xml => '<xml>changed</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    new_install = @user.installs.create!(new_install_attributes.merge(:app => app, :sync => @syncs[1]))
    another_install_attributes = Factory.attributes_for(:install_from_xml, :raw_xml => '<xml>original</xml>')
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    
    @user.synchronize([app_attributes.merge(another_install_attributes)], @syncs[2])
    
    @user.installs.length.should == 3
    another_install = @user.installs.find(:last, :order => 'created_at')
    Install.extract_attributes(another_install.attributes).should == another_install_attributes
  end
  
  it 'should create uninstall if user installed app, synced, uninstalled app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    install = @user.installs.create!(install_attributes.merge(:app => app, :sync => @syncs[0]))
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    
    @user.synchronize([], @syncs[1])
    
    @user.installs.length.should == 2
    uninstall = @user.installs.find(:last, :order => 'created_at')
    uninstall.installed.should == false
    Install.extract_attributes(uninstall.attributes).should == install_attributes
  end
  
  it 'should create install if user installed app, synced, uninstalled app, synced, re-installed app, and synced' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    install = @user.installs.create!(install_attributes.merge(:app => app, :sync => @syncs[0]))
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    uninstall = @user.installs.create!(install_attributes.merge(:installed => false, :app => app, :sync => @syncs[1]))
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    
    @user.synchronize([app_attributes.merge(install_attributes)], @syncs[2])
    
    @user.installs.length.should == 3
    reinstall = @user.installs.find(:last, :order => 'created_at')
    reinstall.installed.should == true
    Install.extract_attributes(reinstall.attributes).should == install_attributes
  end
  
  it 'should not create uninstall if user installed app, synced, uninstalled app, synced, and then synced again' do
    app_attributes = Factory.attributes_for(:app)
    app = App.create!(app_attributes)
    install_attributes = Factory.attributes_for(:install_from_xml)
    Time.stub!(:now).and_return(Time.parse('2009-01-01'))
    install = @user.installs.create!(install_attributes.merge(:app => app, :sync => @syncs[0]))
    Time.stub!(:now).and_return(Time.parse('2009-01-02'))
    uninstall = @user.installs.create!(install_attributes.merge(:installed => false, :app => app, :sync => @syncs[1]))
    Time.stub!(:now).and_return(Time.parse('2009-01-03'))
    
    @user.synchronize([], @syncs[2])
    
    @user.installs.length.should == 2
    uninstall = @user.installs.find(:last, :order => 'created_at')
    uninstall.installed.should == false
    Install.extract_attributes(uninstall.attributes).should == install_attributes
  end
  
end