module ApplicationHelper
  
  def icon(app)
    link_to(image_tag(app.icon.url, :alt => app.name), app_path(app), :class => 'appIcon')
  end
  
  def heading(app)
    content_tag('h3', :class => 'appName') do
      link_to truncate(app.name), app_path(app)
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
  
  def install_event_details(install)
    event = install.installed? ? 'updated' : 'uninstalled'
    attribution = "by #{link_to install.user.login, user_path(install.user)}"
    "#{event} #{attribution} #{time_ago(install.purchased_at)}"
  end
  
  def install_release_details(install)
    "released #{time_ago(install.released_at)}"
  end
  
  def time_ago(time)
    time_ago_in_words(time).gsub(/about /, '') + ' ago'
  end
  
end