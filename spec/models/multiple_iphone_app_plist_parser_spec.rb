require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MultipleIphoneAppPlistParser, 'behaviour' do
  
  it 'should parse concatenated app plists' do
    plists = [build_plist('name-1'), build_plist('name-2')].join("\n")
    apps = MultipleIphoneAppPlistParser.new(plists).unique_apps
    apps.length.should == 2
    apps[0][:name].should == 'name-1'
    apps[1][:name].should == 'name-2'
  end
  
  it 'should only include app with latest purchase date when names are duplicate' do
    app_v1 = build_plist('name', Time.parse('2009-01-01'))
    app_v2 = build_plist('name', Time.parse('2009-01-02'))
    plists = [app_v1, app_v2].join("\n")
    apps = MultipleIphoneAppPlistParser.new(plists).unique_apps
    apps.length.should == 1
    apps[0][:purchased_at].should == Time.parse('2009-01-02')
  end
  
  def build_plist(name, purchased_at = Time.now)
    %{
      <plist version="1.0">
      <dict>
        <key>itemName</key>
        <string>#{name}</string>
        <key>purchaseDate</key>
        <string>#{purchased_at.utc.iso8601}</string>
      </dict>
      </plist>
    }
  end
  
end
