require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/index" do
  before(:each) do
    @accounts = []
    @accounts << stub_model(Account, :name => "name1") << stub_model(Account, :name => "name2") << stub_model(Account, :name => "name3")
  end

  it "should render a collection of account partials" do
    template.should_receive(:render).with(:partial => "account", :collection => @accounts).and_return "rendered from partial"
    assigns[:accounts] = @accounts
    render 'accounts/index.html.erb'
    response.should contain "rendered from partial"
  end
end