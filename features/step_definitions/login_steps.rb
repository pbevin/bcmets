Given /^there is no user called "([^\"]*)"$/ do |name|
  User.delete_all(['name = ?', name])
end

Given /^I am not logged in$/ do
  UserSession.find.destroy rescue nil
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
