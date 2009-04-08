require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArchiveController do

  #Delete these examples and add some real ones
  it "should use ArchiveController" do
    controller.should be_an_instance_of(ArchiveController)
  end


  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'month'" do
    it "should be successful" do
      get 'month'
      response.should be_success
    end
  end

  describe "GET 'article'" do
    it "should be successful" do
      get 'article'
      response.should be_success
    end
  end
end
