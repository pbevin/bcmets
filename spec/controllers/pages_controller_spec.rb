require 'rails_helper'

describe PagesController do
  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should redirect_to '/'
    end
  end
end
