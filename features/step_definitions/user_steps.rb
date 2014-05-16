Given(/^a user exists$/) do
  @user = User.make!
end

Given(/^a user exists with #{capture_fields}$/) do |attrs|
  @user = User.make!(parse_fields attrs)
end

Given(/^the following users exist$/) do |table|
  table.hashes.each do |attrs|
    User.make! attrs
  end
end

Then(/^a user should exist with #{capture_fields}$/) do |attrs|
  User.where(parse_fields attrs).count.should == 1
  @user = User.find_by(parse_fields attrs)
end

Then(/^a user should not exist with #{capture_fields}$/) do |attrs|
  User.where(parse_fields attrs).count.should == 0
end

Given /^the user is active$/ do
  @user.update_attributes(active: true)
end

Given /^the user is not active$/ do
  @user.update_attributes(active: false)
end

Then(/^the user should be active$/) do
  @user.reload.should be_active
end
