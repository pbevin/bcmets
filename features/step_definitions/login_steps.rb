Given /^there is no user called "([^\"]*)"$/ do |name|
  User.delete_all(['name = ?', name])
end

Given /^I am not logged in$/ do
  UserSession.find.destroy rescue nil
end

Then /^I should be logged in$/ do
  UserSession.find.should_not be_nil
end

Then /^I should be logged out$/ do
  UserSession.find.should be_nil
end

Then /^I should not be logged in$/ do
  UserSession.find.should be_nil
end

Given /^that I have a confirmation email/ do
  User.delete_all
  @u = User.new(:name => "Mary Jones", :email => "mary@example.com")
  @u.email_delivery = "none"
  @u.reset_perishable_token!
  @u.signup!
end

When /^I click on the activation link$/ do
  token = @u.perishable_token
  visit "/register/#{token}"
end

Given /^user "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  User.delete_all
  u = User.new(:email => email, :name => "test", :password => password, :password_confirmation => password)
  u.active = true
  u.save!
end

Given /^I sign up as "([^\"]*)"$/ do |email|
  visit "/users/new"
  fill_in "Email", :with => email
  fill_in "Name", :with => "test"
  click_button "Sign up"
end

Given /^(.+) is logged in$/ do |who|
  user = model(who)
  user.activate!
  visit "/login"
  fill_in "Email", :with => user.email
  fill_in "Password", :with => "xyzzy"
  click_button "Login"
end

When /^I activate user "([^\"]*)"$/ do |email|
  user = User.find_by_email(email)
  token = user.perishable_token
  visit "/register/#{token}"
  fill_in "Password", :with => "xyzzy"
  fill_in "Password confirmation", :with => "xyzzy"
  choose('user_email_delivery_full')
  click_button "Sign me up"
end

Then /^(.+) should have password: "([^\"]*)"$/ do |who, password|
  user = model(who)
  user.valid_password?(password).should be_true
end

Then /^(.+) should have been deleted/ do |who|
  begin
    user = model(who)
    fail("User should have been deleted but wasn't")
  rescue ActiveRecord::RecordNotFound
  end
end
