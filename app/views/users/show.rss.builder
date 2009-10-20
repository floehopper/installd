xml = Builder::XmlMarkup.new(:indent => 2)
xml.instruct!
xml_string = xml.rss('xmlns:atom' => "http://www.w3.org/2005/Atom", :version => "2.0") do
  xml.channel do
    xml.title("#{@user.login}'s Apps")
    xml.description("Applications recently updated by #{@user.login} (as recorded on installd.com)")
    xml.link(url_for(:host => HOST))
    xml.language 'en'
    xml.pubDate Time.now.to_s(:rfc822)
    xml.atom(:link, :href => url_for(:host => HOST, :format => 'rss'), :rel => "self", :type => "application/rss+xml")
    @installs.each do |install|
      xml.item do
        xml.title(install.app.name)
        xml.pubDate install.created_at.to_s(:rfc822)
        xml.guid(app_url(install.app, :host => HOST), :isPermaLink => "false")
        xml.link app_url(install.app, :host => HOST)
        xml.description "Updated #{time_ago_in_words(install.purchased_at)} ago"
      end
    end
  end
end
