Given /^I am signed in with login "([^\"]*)" and password "([^\"]*)"$/ do |login, password|
  visit path_to('the sign-in page')
  fill_in 'Login', :with => login
  fill_in 'Password', :with => password
  click_button 'Sign In'
end
