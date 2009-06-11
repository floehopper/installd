Then /^I should see an application with name "([^\"]*)"$/ do |name|
  response.should have_tag('.install > .app > a.name', :text => name)
end
