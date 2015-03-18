require 'rails_helper'

describe TimelineController do
  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end

    it "assigns @posts" do
      12.times { Article.make! }
      get 'index'
      expect(assigns(:posts).length).to eq(10)
    end
  end
end
