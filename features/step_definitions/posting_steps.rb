Given /^I am logged in as "([^\"]*)"$/ do |email|
  u = User.find_by_email(email)
  u.password = "xyzzy"
  u.activate!
  u.save!
  visit "/login"
  fill_in "Email", with: email
  fill_in "Password", with: "xyzzy"
  click_button "Login"
  page.should have_content("Logged in")
end

Given(/^a parent article exists with #{capture_fields}$/) do |attrs|
  @article = @parent = Article.make! parse_fields(attrs)
end

When /^I post an article$/ do
  visit post_path
  fill_in "Subject", with: Faker::Lorem.sentence
  fill_in "Message", with: Faker::Lorem.paragraph
  click_button "Post"
  page.should have_content("Message sent")
end

Then /^there should be an article with user "([^\"]*)"$/ do |email|
  Article.first.user.should_not be_nil
  Article.first.user.email.should == email
end

When /^I post an article with email "([^\"]*)"$/ do |email|
  visit post_path
  fill_in "Name", with: Faker::Name.name
  fill_in "Email", with: email
  fill_in "Subject", with: Faker::Lorem.sentence
  fill_in "Message", with: Faker::Lorem.paragraph
  click_button "Post"
  page.should have_content("Message sent")
end

Then /^no article should exist$/ do
  Article.count.should == 0
end

Then(/^the "(.*?)" button should be inactive$/) do |name|
  expect(page).to have_selector("button[disabled]", text: name)
end

When /^an article arrives with email "([^\"]*)"$/ do |email|
  Article.create!(
    email: email,
    name: Faker::Name.name,
    subject: Faker::Lorem.sentence,
    body: Faker::Lorem.paragraph)
end

Then /^no article should be queued$/ do
  ActionMailer::Base.deliveries.length.should == 0
end

Then /^an article should be queued with subject: "([^\"]*)"$/ do |subject|
  ActionMailer::Base.deliveries.length.should == 1

  msg = ActionMailer::Base.deliveries.first
  msg.subject.should == subject
end

Then /^an article should be queued with email: "([^\"]*)", parent_msgid: "([^\"]*)"$/ do |email, parent_msg_id|
  ActionMailer::Base.deliveries.length.should == 1

  msg = ActionMailer::Base.deliveries.first
  msg.from.should == [email]
  msg.header["in-reply-to"].value.should == parent_msg_id
end
