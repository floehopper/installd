class MultipleIphoneAppPlistParser
  
  def initialize(io)
    @apps = []
    while !io.eof? do
      plist = StringIO.new
      line = ''
      while !io.eof? && line != '</plist>' do
        line = io.readline.strip.chomp
        plist.puts(line) unless line.empty?
      end
      plist.rewind
      unless plist.length == 0
        doc = Hpricot::XML(plist.read)
        plist_element = (doc/'plist')[0]
        @apps << IphoneAppPlistParser.new(plist_element).attributes
      end
    end
  end
  
  def unique_apps
    names_vs_apps = @apps.group_by { |app| app[:name] }
    names_vs_apps.map do |(name, apps)|
      apps.sort_by { |app| app[:purchased_at] }.last
    end
  end
  
end

