xml = Builder::XmlMarkup.new(:indent => 2)
xml.instruct!
xml_string = xml.rss('xmlns:atom' => "http://www.w3.org/2005/Atom", :version => "2.0") do
  xml.channel do
    if @user
      xml.title("#{@user.login}'s Recent Events")
    else
      xml.title("Recent Events")
    end
    xml.description("Events recently reported to installd.com")
    xml.link(url_for(:host => HOST))
    xml.language 'en'
    xml.pubDate Time.now.to_s(:rfc822)
    xml.atom(:link, :href => url_for(:host => HOST, :format => 'rss'), :rel => "self", :type => "application/rss+xml")
    @events.each do |event|
      xml.item do
        app = event.app
        xml.title(app.name)
        xml.pubDate event.created_at.to_s(:rfc822)
        xml.guid(app_url(app, :host => HOST), :isPermaLink => "false")
        xml.link app_url(app, :host => HOST)
        xml.description "#{event_details(event).capitalize}. #{release_details(event).capitalize}."
      end
    end
  end
end
