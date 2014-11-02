require 'rails_helper'

describe UserSessionsController do
  it "doesn't let an unconfirmed user login" do
    with_unconfirmed_user do |user|
      post :create, user_session: { email: user.email, password: "secret" }
      controller.current_user.should be_nil
      assigns[:user_session].errors[:base].inspect.should == '["Your account is not active"]'
    end
  end

  def with_unconfirmed_user
    user = User.make!
    user.active = false
    yield user
  end
end
