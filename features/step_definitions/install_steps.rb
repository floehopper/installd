Then /^I should see an application with name "([^\"]*)"$/ do |name|
  app = App.find_by_name(name)
  response.should have_tag("##{app.to_param}")
end
