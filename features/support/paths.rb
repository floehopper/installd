module NavigationHelpers
  def path_to(page_name)
    case page_name
    
    when /the home page/
      root_path
    
    when /the sign-in page/
      new_user_session_path
    
    when /the registration page/
      new_user_path
    
    when /the user page for "([^\"]*)"/
      user_path($1)
    
    when /the user installs page for "([^\"]*)"/
      user_installs_path($1)
    
    when /the user friends installs page for "([^\"]*)"/
      user_friends_installs_path($1)
    
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in features/support/paths.rb"
    end
  end
end

World do |world|
  world.extend NavigationHelpers
  world
end
