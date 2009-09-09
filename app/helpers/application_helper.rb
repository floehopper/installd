module ApplicationHelper
  
  def icon(app)
    link_to(image_tag(app.icon.url, :alt => app.name), app.url, :class => 'appIcon')
  end
  
  def heading(app)
    content_tag('h3', :class => 'appName') do
      link_to truncate(app.name), app_path(app)
    end
  end
  
  def stars(install)
    returning String.new do |stars|
      (1..5).each do |rating|
        if install.rating && install.rating >= rating
          stars << content_tag('div', :class => 'star-rating star-rating-readonly star-rating-on') do
            content_tag('a', :title => rating) do
              rating
            end
          end
        else
          stars << content_tag('div', :class => 'star-rating star-rating-readonly') do
            content_tag('a', :title => rating) do
              rating
            end
          end
        end
      end
    end
  end
  
end
