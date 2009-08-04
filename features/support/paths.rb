module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the homepage/
    	'/'
  	when /the login page/
  		'/users/login'
  	when /the Account index page/i
  		'/accounts'
  	when /the New Account page/i
  		'/accounts/new'
  	when /the edit account page for (.*)/i
  	  edit_account_path(Account.find_by_name($1))
  	when /the Account main page/i
  	  '/accounts/index'
    
    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
