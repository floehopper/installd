xml = Builder::XmlMarkup.new(:indent => 2)
xml.instruct!
xml_string = xml.rss('xmlns:atom' => "http://www.w3.org/2005/Atom", :version => "2.0") do
  xml.channel do
    xml.title("#{@user.login}'s Network")
    xml.description("Applications recently installed users in #{@user.login}'s network (as recorded on installd.com)")
    xml.link(url_for(:host => HOST))
    xml.language 'en'
    xml.pubDate Time.now.to_s(:rfc822)
    xml.atom(:link, :href => url_for(:host => HOST, :format => 'rss'), :rel => "self", :type => "application/rss+xml")
    @connected_installs.each do |app, installs|
      xml.item do
        xml.title(app.name)
        xml.pubDate installs.map(&:created_at).max.to_s(:rfc822)
        xml.guid(app_url(app, :host => HOST), :isPermaLink => "false")
        xml.link app.url
      end
    end
  end
end
