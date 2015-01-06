require 'rails_helper'

describe UsersController do
  let(:queue) { instance_spy(SubscriberEvent::Queue) }

  before(:each) do
    controller.stub :require_admin
    SubscriberEvent.queue = queue
  end

  after(:each) do
    SubscriberEvent.queue = nil
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
    let(:user) { User.make! }

    it "creates a subscriber event" do
      delete :destroy, id: user.id

      expect(queue).to have_received(:notify_destroyed).with(user)
    end
  end

  describe '#update' do
    let(:user) { User.make! }

    it "can update email_delivery" do
      allow(controller).to receive(:current_user).and_return(user)
      patch :update, id: "current", user: { email_delivery: "digest" }
      expect(user.reload.email_delivery).to eq("digest")
    end
  end

end
