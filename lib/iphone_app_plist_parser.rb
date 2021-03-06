class IphoneAppPlistParser
  
  class NullElement
    def inner_text; nil; end
    def /(xpath); []; end
  end
  
  def initialize(plist_element)
    @plist_element = plist_element
  end
  
  def attributes
    dict = @plist_element/'dict'
    purchaseDate = value_for_key(dict, 'purchaseDate')
    downloadInfo = element_for_key(dict, 'com.apple.iTunesStore.downloadInfo')
    purchaseDate ||= value_for_key(downloadInfo, 'purchaseDate')
    attributes = {
      :artist_name => value_for_key(dict, 'artistName'),
      :artist_id => value_for_key(dict, 'artistId'),
      :genre => value_for_key(dict, 'genre'),
      :genre_id => value_for_key(dict, 'genreId'),
      :name => value_for_key(dict, 'itemName'),
      :item_id => value_for_key(dict, 'itemId'),
      :icon_url => value_for_key(dict, 'softwareIcon57x57URL'),
      :price => integer(value_for_key(dict, 'price'), 0),
      :display_price => string(value_for_key(dict, 'priceDisplay'), 'UNKNOWN'),
      :purchased_at => time(purchaseDate),
      :released_at => time(value_for_key(dict, 'releaseDate')),
      :store_code => value_for_key(dict, 's'),
      :software_version_bundle_id => value_for_key(dict, 'softwareVersionBundleId'),
      :software_version_external_identifier => value_for_key(dict, 'softwareVersionExternalIdentifier'),
      :raw_xml => @plist_element.to_s
    }
  end
  
  private
  
  def element_for_key(root, key)
    element = (root/"key[text()='#{key}']").first
    element ? element.next_sibling : NullElement.new
  end
  
  def value_for_key(root, key)
    element = element_for_key(root, key)
    element ? element.inner_text : nil
  end
  
  def string(text, default = nil)
    text.blank? ? default : text
  end
  
  def integer(text, default = nil)
    text.blank? ? default : Integer(text) rescue default
  end
  
  def time(text, default = nil)
    text.blank? ? default : Time.parse(text) rescue default
  end
  
end