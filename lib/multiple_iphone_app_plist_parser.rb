class MultipleIphoneAppPlistParser
  
  def initialize(doc)
    @doc = Hpricot::XML(doc)
    @apps = (@doc/'plist').map do |plist_element|
      IphoneAppPlistParser.new(plist_element).attributes
    end
  end
  
  def unique_apps
    names_vs_apps = @apps.group_by { |app| app[:name] }
    names_vs_apps.map do |(name, apps)|
      apps.sort_by { |app| app[:purchased_at] }.last
    end
  end
  
end

