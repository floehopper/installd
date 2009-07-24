xml = Builder::XmlMarkup.new(:indent => 2)
xml.instruct!
xml_string = xml.rss('xmlns:atom' => "http://www.w3.org/2005/Atom", :version => "2.0") do
  xml.channel do
    xml.title("#{@user.login}'s Apps")
    xml.description("Applications recently installed by #{@user.login} as recorded on installd.com")
    xml.link(user_url(@user, :host => HOST))
    xml.language 'en'
    xml.pubDate Time.now.to_s(:rfc822)
    xml.atom(:link, :href => user_url(@user, :host => HOST, :format => 'rss'), :rel => "self", :type => "application/rss+xml")
    @installs.each do |install|
      xml.item do
        xml.title(install.app.name)
        xml.pubDate install.created_at.to_s(:rfc822)
        xml.guid(app_url(install.app, :host => HOST), :isPermaLink => "false")
        xml.link install.app.url
      end
    end
  end
end
