module ApplicationHelper
  
  def icon(app)
    link_to(image_tag(app.icon.url, :alt => app.name), app.url, :class => 'appIcon')
  end
  
  def heading(app)
    content_tag('h3', :class => 'appName') do
      link_to truncate(app.name), app_path(app)
    end
  end
  
end
