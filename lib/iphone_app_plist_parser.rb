class IphoneAppPlistParser
  
  class NullElement
    def inner_text; nil; end
    def /(xpath); []; end
  end
  
  def initialize(doc)
    @doc = Hpricot::XML(doc)
    @first_plist = (@doc/'plist').first
  end
  
  def each_app
    (@doc/'plist').each do |plist|
      yield(attributes(plist)) if block_given?
    end
  end
  
  def attributes(plist = @first_plist)
    dict = plist/'dict'
    purchaseDate = value_for_key(dict, 'purchaseDate')
    downloadInfo = element_for_key(dict, 'com.apple.iTunesStore.downloadInfo')
    purchaseDate ||= value_for_key(downloadInfo, 'purchaseDate')
    attributes = {
      :itemName => value_for_key(dict, 'itemName'),
      :itemId => value_for_key(dict, 'itemId'),
      :softwareIcon57x57URL => value_for_key(dict, 'softwareIcon57x57URL'),
      :purchaseDate => purchaseDate ? Time.parse(purchaseDate) : nil,
      :rawXML => plist.to_s
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
  
end
