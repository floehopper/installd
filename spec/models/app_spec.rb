require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe App, 'URL-friendly identifier' do
  
  it 'should generate identifier based on name' do
    app = Factory.create(:app, :name => 'onetwothree')
    app.identifier.should == 'onetwothree'
  end
  
  it 'should not change identifier on save after creation' do
    app = Factory.create(:app, :name => 'onetwothree')
    app.save
    app.identifier.should == 'onetwothree'
  end
  
  it 'should allow hyphens' do
    app = Factory.create(:app, :name => "one-two-three")
    app.identifier.should == 'one-two-three'
  end
  
  it 'should allow uppercase and lowercase letters but convert to lowercase' do
    app = Factory.create(:app, :name => "oNe-Two-threE")
    app.identifier.should == 'one-two-three'
  end
  
  it 'should allow digits' do
    app = Factory.create(:app, :name => "1-two-3")
    app.identifier.should == '1-two-3'
  end
  
  it 'should replace consecutive whitespace characters with a single hyphen' do
    app = Factory.create(:app, :name => "one two  three")
    app.identifier.should == 'one-two-three'
  end
  
  it 'should replace consecutive non-alphanumeric characters with a single hyphen' do
    app = Factory.create(:app, :name => "one%*!two$&?three")
    app.identifier.should == 'one-two-three'
  end
  
  it 'should replace tildes with a single hyphen' do
    app = Factory.create(:app, :name => "one~two~three")
    app.identifier.should == 'one-two-three'
  end
  
  it 'should remove leading and trailing whitespace characters' do
    app = Factory.create(:app, :name => "  onetwothree\t")
    app.identifier.should == 'onetwothree'
  end
  
  it 'should append suffix when existing name does map to same identifier' do
    Factory.create(:app, :name => 'one-two-three')
    app = Factory.create(:app, :name => 'one two three')
    app.identifier.should == 'one-two-three~1'
  end
  
  it 'should not append suffix when existing name does not map to same identifier' do
    Factory.create(:app, :name => 'one-two-three-123-four')
    app = Factory.create(:app, :name => 'one two three')
    app.identifier.should == 'one-two-three'
  end
  
end
