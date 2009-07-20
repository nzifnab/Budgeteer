module ControllerHelpers
  def login_as_user
    login_user = mock_model(User)
    controller.stub!(:current_user).and_return login_user
    return login_user
  end
  
  def logout_user
    controller.stub!(:current_user).and_return false
  end
end