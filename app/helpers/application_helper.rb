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
  
end