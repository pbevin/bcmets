require 'rails_helper'

describe UsersController do
  before(:each) do
    controller.stub :require_admin
  end

  it "provides a signup form" do
    get :new
    response.should be_success
  end

  it "requires email and name during signup" do
    post :create, user: { name: "", email: "" }
    assigns[:user].id.should be_nil

    post :create, user: { name: "just a name" }
    assigns[:user].id.should be_nil

    post :create, user: { email: "email@example.com" }
    assigns[:user].id.should be_nil

    post :create, user: { name: "Joe", email: "joe@example.com" }
    assigns[:user].id.should_not be_nil
  end

  describe "destroy" do
    let(:queue) { instance_spy(SubscriberEvent::Queue) }
    let(:user) { User.make! }

    before(:each) do
      SubscriberEvent.queue = queue
    end

    it "creates a subscriber event" do
      delete :destroy, id: user.id

      expect(queue).to have_received(:notify_destroyed).with(user)
    end
  end
end
