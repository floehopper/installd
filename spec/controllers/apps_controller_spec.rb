require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe AppsController, 'show' do
  
  it 'should render page for app' do
    app = Factory.create(:app)
    
    get :show, :id => app.identifier
    
    assigns[:app].should == app
    response.should render_template(:show)
  end
  
  it 'should permanently redirect to page for app for old URLs using database ID' do
    app = Factory.create(:app)
    
    get :show, :id => app.id
    
    assigns[:app].should == app
    response.should redirect_to(app_path(app))
    response.status.should == '301 Moved Permanently'
  end
  
end