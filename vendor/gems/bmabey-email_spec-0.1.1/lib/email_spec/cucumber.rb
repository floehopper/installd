# require this in your env.rb file after you require cucumber/rails/world

# Global Setup
ActionMailer::Base.delivery_method = :test unless ActionMailer::Base.delivery_method == :activerecord
ActionMailer::Base.perform_deliveries = true

Before do
  # Scenario setup
  ActionMailer::Base.deliveries.clear if ActionMailer::Base.delivery_method == :test
end

After do
  EmailSpec::EmailViewer.save_and_open_all_raw_emails if ENV['SHOW_EMAILS']
  EmailSpec::EmailViewer.save_and_open_all_html_emails if ENV['SHOW_HTML_EMAILS']
  EmailSpec::EmailViewer.save_and_open_all_text_emails if ENV['SHOW_TEXT_EMAILS']
end

World do |world|
  world.extend EmailSpec::Helpers
  world.extend EmailSpec::Matchers
end
