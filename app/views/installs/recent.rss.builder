xml = Builder::XmlMarkup.new(:indent => 2)
xml.instruct!
xml_string = xml.rss('xmlns:atom' => "http://www.w3.org/2005/Atom", :version => "2.0") do
  xml.channel do
    xml.title("Recent Apps")
    xml.description("Applications recently installed (as recorded on installd.com)")
    xml.link(url_for(:host => HOST))
    xml.language 'en'
    xml.pubDate Time.now.to_s(:rfc822)
    xml.atom(:link, :href => url_for(:host => HOST, :format => 'rss'), :rel => "self", :type => "application/rss+xml")
    @installs.each do |install|
      xml.item do
        xml.title(install.app.name)
        xml.pubDate install.created_at.to_s(:rfc822)
        xml.guid(app_url(install.app, :host => HOST), :isPermaLink => "false")
        xml.link install.app.url
        xml.description "Purchased by #{link_to install.user.login, user_path(install.user)} #{time_ago_in_words(install.purchased_at).gsub(/about /, '')} ago for #{install.display_price.downcase}"
      end
    end
  end
end
