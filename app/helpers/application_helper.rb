module ApplicationHelper
  
  def icon(app)
    link_to(image_tag(app.icon.url, :alt => app.name), app_path(app), :class => 'appIcon')
  end
  
  def heading(app)
    content_tag('h3', :class => 'appName') do
      link_to truncate(app.name), app_path(app)
    end
  end
  
  def column_heading(title, path)
    content_tag('h2', :class => 'pageHeading') do
      link_to title, path
    end
  end
  
  def stars(rating)
    content_tag 'div', :class => 'rating' do
      returning String.new do |content|
        (1..5).each do |index|
          if rating
            if rating >= index
              content << content_tag('div', :class => 'star-rating star-rating-readonly star-rating-on') do
                content_tag('a', :title => "rated #{rating} out of 5") do
                  rating
                end
              end
            else
              content << content_tag('div', :class => 'star-rating star-rating-readonly') do
                content_tag('a', :title => "rated #{rating} out of 5") do
                  rating
                end
              end
            end
          end
        end
      end
    end
  end
  
  def buy_link(app)
    url = "http://clkuk.tradedoubler.com/click?p=23708&a=1710525&url=" + CGI.escape(app.url + "&uo=6&partnerId=2003")
    link_to(image_tag('badgeitunes61x15dark.gif', :size => "61x15", :alt => app.name), url, :class => 'buy')
  end
  
  def html_description(app)
    paragraphs = (app.description || '').split("\n\n")
    paragraphs.map do |paragraph|
      paragraph_with_linebreaks = paragraph.gsub(/\n/, "<br />")
      "<p>#{paragraph_with_linebreaks}</p>"
    end
  end
  
  def event_details(event)
    case event.state
      when 'Initial'
        event_type, event_time = 'first synced', event.created_at
      when 'Install'
        event_type, event_time = 'installed', event.purchased_at
      when 'Update'
        event_type, event_time = 'updated', event.purchased_at
      when 'Uninstall'
        event_type, event_time = 'uninstalled', event.created_at
    end
    attribution = "by #{link_to event.user.login, user_path(event.user)}"
    "#{event_type} #{attribution} #{time_ago(event_time)}"
  end
  
  def release_details(event)
    "released #{time_ago(event.released_at)}"
  end
  
  def time_ago(time)
    time_ago_in_words(time).gsub(/about /, '') + ' ago'
  end
  
end