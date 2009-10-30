Then /^Google should be disabled$/ do
  response.should have_tag("head>meta")
end

Then /^Google should be enabled$/ do
  response.should_not have_tag("head>meta[name=robots]")
end

When /^I go to the archives at "([^\"]*)"/ do |path|
  visit "/archive/#{page}"
end

Given /^there is an article posted on "([^\"]*)"$/ do |date|
  Article.make(:received_at => date)
end

Given /^there is an article posted on "([^\"]*)" with subject "([^\"]*)"$/ do |date, subject|
  Article.make(:received_at => date, :subject => subject)
end

