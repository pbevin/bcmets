Given /^I am logged in as "([^\"]*)"$/ do |email|
  u = User.find_by_email(email)
  u.password = "xyzzy"
  u.activate!
  u.save!
  visit "/login"
  fill_in "Email", :with => email
  fill_in "Password", :with => "xyzzy"
  click_button "Login"
  response.should contain("Logged in")
end

When /^I post an article$/ do
  visit post_path
  fill_in "Subject", :with => Faker::Lorem.sentence
  fill_in "article_qt", :with => Faker::Lorem.paragraph
  click_button "Post"
  response.should contain("Message sent")
end

Then /^there should be an article with user "([^\"]*)"$/ do |email|
  Article.first.user.should_not be_nil
  Article.first.user.email.should == email
end

When /^I post an article with email "([^\"]*)"$/ do |email|
  visit post_path
  fill_in "Name", :with => Faker::Name.name
  fill_in "Email", :with => email
  fill_in "Subject", :with => Faker::Lorem.sentence
  fill_in "article_qt", :with => Faker::Lorem.paragraph
  click_button "Post"
  response.should contain("Message sent")
end

Then /^no article should exist$/ do
  Article.count.should == 0
end

When /^an article arrives with email "([^\"]*)"$/ do |email|
  Article.create!(
    :email => email,
    :name => Faker::Name.name,
    :subject => Faker::Lorem.sentence,
    :body => Faker::Lorem.paragraph)
end

Then /^no article should be queued$/ do
  pending
end

Then /^an article should be queued with subject: "([^\"]*)"$/ do |arg1|
  pending
end

Then /^an article should queued with email: "([^\"]*)", parent_msgid: "([^\"]*)"$/ do |arg1, arg2|
  pending
end



