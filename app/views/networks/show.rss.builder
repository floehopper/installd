xml = Builder::XmlMarkup.new(:indent => 2)
xml.instruct!
xml_string = xml.rss('xmlns:atom' => "http://www.w3.org/2005/Atom", :version => "2.0") do
  xml.channel do
    xml.title("#{@user.login}'s Network")
    xml.description("Applications recently updated by users in #{@user.login}'s network (as recorded on installd.com)")
    xml.link(url_for(:host => HOST))
    xml.language 'en'
    xml.pubDate Time.now.to_s(:rfc822)
    xml.atom(:link, :href => url_for(:host => HOST, :format => 'rss'), :rel => "self", :type => "application/rss+xml")
    @apps.each do |app|
      xml.item do
        xml.title(app.name)
        event = app.most_recently_added_event
        xml.pubDate event.created_at.to_s(:rfc822)
        xml.guid(app_url(app, :host => HOST), :isPermaLink => "false")
        xml.link app_url(app, :host => HOST)
        xml.description "Updated by #{pluralize(app.events.size, 'user')}. Most recently #{event_details(event)}"
      end
    end
  end
end
