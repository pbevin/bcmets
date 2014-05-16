require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  it "provides a signup form" do
    get :new
    response.should be_success
  end

  it "requires email and name during signup" do
    post :create, :user => { name: "", email: "" }
    assigns[:user].id.should be_nil

    post :create, :user => { :name => "just a name" }
    assigns[:user].id.should be_nil

    post :create, :user => { :email => "email@example.com" }
    assigns[:user].id.should be_nil

    post :create, :user => { :name => "Joe", :email => "joe@example.com" }
    assigns[:user].id.should_not be_nil
  end
end
