require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/login" do
	it "should render a form to login" do
		render "users/login.html.erb"
		response.should have_selector("form[method=post]", :action => enter_users_path) do |form|
			form.should have_selector(
				"input[type=text]",
				:name => "user[username]"
			)
			form.should have_selector(
				"input[type=password]",
				:name => "user[password]"
			)
			form.should have_selector("input[type=submit]")
		end
	end
end
