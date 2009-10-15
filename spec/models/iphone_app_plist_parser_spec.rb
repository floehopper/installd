require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IphoneAppPlistParser, 'each' do
  
  it "should parse artist names" do
    results = parsed_attributes(two_app_plists)
    assert_equal 'Quan Lam', results[0][:artist_name]
    assert_equal 'Facebook', results[1][:artist_name]
  end
  
  it "should parse artist ids" do
    results = parsed_attributes(two_app_plists)
    assert_equal '298794841', results[0][:artist_id]
    assert_equal '284882218', results[1][:artist_id]
  end
  
  it "should parse genres" do
    results = parsed_attributes(two_app_plists)
    assert_equal 'Utilities', results[0][:genre]
    assert_equal 'Social Networking', results[1][:genre]
  end
  
  it "should parse genre ids" do
    results = parsed_attributes(two_app_plists)
    assert_equal '6002', results[0][:genre_id]
    assert_equal '6005', results[1][:genre_id]
  end
  
  it "should parse names" do
    results = parsed_attributes(two_app_plists)
    assert_equal 'SciCal Lite - Scientific Calculator', results[0][:name]
    assert_equal 'Facebook', results[1][:name]
  end
  
  it "should parse item ids" do
    results = parsed_attributes(two_app_plists)
    assert_equal '298967526', results[0][:item_id]
    assert_equal '284882215', results[1][:item_id]
  end
  
  it "should parse prices" do
    results = parsed_attributes(two_app_plists)
    assert_equal 0, results[0][:price]
    assert_equal 199, results[1][:price]
  end
  
  it "should parse display prices" do
    results = parsed_attributes(two_app_plists)
    assert_equal 'FREE', results[0][:display_price]
    assert_equal '£1.99', results[1][:display_price]
  end
  
  it "should parse released at" do
    results = parsed_attributes(two_app_plists)
    assert_equal Time.parse('Mar 02 20:06:25 UTC 2009'), results[0][:released_at]
    assert_equal Time.parse('Jul 10 07:00:00 UTC 2008'), results[1][:released_at]
  end
  
  it "should parse store codes" do
    results = parsed_attributes(two_app_plists)
    assert_equal '143444', results[0][:store_code]
    assert_equal '143444', results[1][:store_code]
  end
  
  it "should parse icon urls" do
    results = parsed_attributes(two_app_plists)
    assert_equal 'http://a1.phobos.apple.com/eu/r30/Purple/9a/78/b7/mzl.uiqhsofr.png', results[0][:icon_url]
    assert_equal 'http://a1.phobos.apple.com/eu/r1000/039/Purple/56/44/f6/mzl.sftqmqlp.png', results[1][:icon_url]
  end
  
  it "should parse purchased at" do
    results = parsed_attributes(two_app_plists)
    assert_equal Time.parse('Aug 02 23:16:25 UTC 2009'), results[0][:purchased_at]
    assert_equal Time.parse('Jul 26 18:20:00 UTC 2009'), results[1][:purchased_at]
  end
  
  it "should parse software version bundle id" do
    results = parsed_attributes(two_app_plists)
    assert_equal 'com.quanlam.scicallite', results[0][:software_version_bundle_id]
    assert_equal 'com.facebook.Facebook', results[1][:software_version_bundle_id]
  end
  
  it "should parse software version external identifier" do
    results = parsed_attributes(two_app_plists)
    assert_equal '1491255', results[0][:software_version_external_identifier]
    assert_equal '1751102', results[1][:software_version_external_identifier]
  end
  
  it "should should capture raw xml" do
    results = parsed_attributes(two_app_plists)
    assert_not_nil results[0][:raw_xml]
    assert_not_nil results[1][:raw_xml]
  end
  
  it "should should not raise exception when xml elements are missing" do
    assert_nothing_raised { parsed_attributes(two_empty_app_plists) }
  end
  
  private
  
  def parsed_attributes(xml)
    parser = IphoneAppPlistParser.new(xml)
    results = []
    parser.each { |attributes| results << attributes }
    results
  end
  
  def two_app_plists
    %{
      <plist version="1.0">
      <dict>
        <key>artistId</key>
        <integer>298794841</integer>
        <key>artistName</key>
        <string>Quan Lam</string>
        <key>buy-only</key>
        <true />
        <key>buyParams</key>
        <string>productType=C&amp;salableAdamId=298967526&amp;pricingParameters=STDQ&amp;price=0&amp;ct-id=14</string>
        <key>com.apple.iTunesStore.downloadInfo</key>
        <dict>
          <key>accountInfo</key>
          <dict>
            <key>AccountKind</key>
            <integer>0</integer>
            <key>AppleID</key>
            <string>james.mead@mail.com</string>
            <key>CreditDisplayString</key>
            <string></string>
            <key>DSPersonID</key>
            <integer>27821071</integer>
          </dict>
          <key>artworkAssetFilename</key>
          <string>298967526-80000680554659.jpg</string>
          <key>mediaAssetFilename</key>
          <string>298967526-80000680554659.ipa</string>
          <key>purchaseDate</key>
          <string>2009-08-02T23:16:25Z</string>
        </dict>
        <key>copyright</key>
        <string>© 2008 Quan Lam</string>
        <key>drmVersionNumber</key>
        <integer>0</integer>
        <key>fileExtension</key>
        <string>.app</string>
        <key>genre</key>
        <string>Utilities</string>
        <key>genreId</key>
        <integer>6002</integer>
        <key>itemId</key>
        <integer>298967526</integer>
        <key>itemName</key>
        <string>SciCal Lite - Scientific Calculator</string>
        <key>kind</key>
        <string>software</string>
        <key>playlistArtistName</key>
        <string>Quan Lam</string>
        <key>playlistName</key>
        <string>SciCal Lite - Scientific Calculator</string>
        <key>price</key>
        <integer>0</integer>
        <key>priceDisplay</key>
        <string>FREE</string>
        <key>rating</key>
        <dict>
          <key>content</key>
          <string></string>
          <key>label</key>
          <string>Not yet rated</string>
          <key>rank</key>
          <integer>600</integer>
          <key>system</key>
          <string>itunes-games</string>
        </dict>
        <key>releaseDate</key>
        <string>2009-03-02T20:06:25Z</string>
        <key>s</key>
        <integer>143444</integer>
        <key>softwareIcon57x57URL</key>
        <string>http://a1.phobos.apple.com/eu/r30/Purple/9a/78/b7/mzl.uiqhsofr.png</string>
        <key>softwareIconNeedsShine</key>
        <true />
        <key>softwareSupportedDeviceIds</key>
        <array>
          <integer>1</integer>
        </array>
        <key>softwareVersionBundleId</key>
        <string>com.quanlam.scicallite</string>
        <key>softwareVersionExternalIdentifier</key>
        <integer>1491255</integer>
        <key>softwareVersionExternalIdentifiers</key>
        <array>
          <integer>1376571</integer>
          <integer>1411831</integer>
          <integer>1417516</integer>
          <integer>1426583</integer>
          <integer>1443095</integer>
          <integer>1491255</integer>
        </array>
        <key>vendorId</key>
        <integer>166017</integer>
        <key>versionRestrictions</key>
        <integer>16843008</integer>
      </dict>
      </plist>
      <plist version="1.0">
      <dict>
        <key>appleId</key>
        <string>james.mead@mail.com</string>
        <key>artistId</key>
        <integer>284882218</integer>
        <key>artistName</key>
        <string>Facebook</string>
        <key>buy-only</key>
        <true />
        <key>buyParams</key>
        <string>productType=C&amp;salableAdamId=284882215&amp;pricingParameters=STDQ&amp;price=0&amp;ct-id=14</string>
        <key>copyright</key>
        <string>© Facebook, Inc.</string>
        <key>drmVersionNumber</key>
        <integer>0</integer>
        <key>fileExtension</key>
        <string>.app</string>
        <key>genre</key>
        <string>Social Networking</string>
        <key>genreId</key>
        <integer>6005</integer>
        <key>itemId</key>
        <integer>284882215</integer>
        <key>itemName</key>
        <string>Facebook</string>
        <key>kind</key>
        <string>software</string>
        <key>playlistArtistName</key>
        <string>Facebook</string>
        <key>playlistName</key>
        <string>Facebook</string>
        <key>price</key>
        <integer>199</integer>
        <key>priceDisplay</key>
        <string>£1.99</string>
        <key>purchaseDate</key>
        <date>2009-07-26T18:20:00Z</date>
        <key>rating</key>
        <dict>
          <key>content</key>
          <string></string>
          <key>label</key>
          <string>Not yet rated</string>
          <key>rank</key>
          <integer>600</integer>
          <key>system</key>
          <string>itunes-games</string>
        </dict>
        <key>releaseDate</key>
        <string>2008-07-10T07:00:00Z</string>
        <key>s</key>
        <integer>143444</integer>
        <key>softwareIcon57x57URL</key>
        <string>http://a1.phobos.apple.com/eu/r1000/039/Purple/56/44/f6/mzl.sftqmqlp.png</string>
        <key>softwareIconNeedsShine</key>
        <false />
        <key>softwareSupportedDeviceIds</key>
        <array>
          <integer>1</integer>
        </array>
        <key>softwareVersionBundleId</key>
        <string>com.facebook.Facebook</string>
        <key>softwareVersionExternalIdentifier</key>
        <integer>1751102</integer>
        <key>softwareVersionExternalIdentifiers</key>
        <array>
          <integer>18372</integer>
          <integer>23552</integer>
          <integer>478761</integer>
          <integer>1427863</integer>
          <integer>1452591</integer>
          <integer>1551411</integer>
          <integer>1690253</integer>
          <integer>1751102</integer>
        </array>
        <key>url</key>
        <string>http://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=284882215&amp;mt=8</string>
        <key>vendorId</key>
        <integer>10684</integer>
        <key>versionRestrictions</key>
        <integer>16843008</integer>
      </dict>
      </plist>
    }
  end
  
  def two_empty_app_plists
    %{
      <plist version="1.0">
      <dict>
      </dict>
      </plist>
      <plist version="1.0">
      <dict>
      </plist>
    }
  end
  
end