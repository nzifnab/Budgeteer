class UsersController < ApplicationController
	def login
	end
	
	def logout
	  session[:user_id] = nil
	  redirect_to accounts_path
  end
	
	def enter
		if( User.authenticate( params[:user][:username], params[:user][:password] ) )
			user = User.find_by_username(params[:user][:username])
			session[:user_id] = user.id
			flash[:notice] = "Login Successful"
			redirect_to accounts_path
		else
			session[:user_id] = nil
			flash[:warning] = "Invalid Username or Password"
			redirect_to login_users_path
		end
	end
end
