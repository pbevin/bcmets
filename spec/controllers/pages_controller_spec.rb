require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do
  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should redirect_to '/'
    end
  end
end
