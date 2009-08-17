require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Income do
  before(:each) do
    @valid_attributes = {
      :amount => 1.5,
      :description => "value for description",
      :user_id => 1
    }
  end

  it "should create a new instance given valid attributes" do
    Income.create!(@valid_attributes)
  end
end
