require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  it "provides a signup form" do
    get :new
    response.should be_success
  end
  
  it "requires email and name during signup" do
    post :create, :user => { }
    assigns[:user].should be_new_record
    
    post :create, :user => { :name => "just a name" }
    assigns[:user].should be_new_record
    
    post :create, :user => { :email => "email@example.com" }
    assigns[:user].should be_new_record
    
    post :create, :user => { :name => "Joe", :email => "joe@example.com" }
    assigns[:user].should_not be_new_record
  end
end