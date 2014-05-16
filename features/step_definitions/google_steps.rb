Then /^Google should be disabled$/ do
  page.should have_selector("head meta[name='robots']", visible: false)
end

Then /^Google should be enabled$/ do
  page.should_not have_selector("head>meta[name=robots]", visible: false)
end

When /^I go to the archives at "([^\"]*)"/ do |path|
  visit "/archive/#{page}"
end

Given /^there is an article posted on "([^\"]*)"$/ do |date|
  Article.make!(received_at: date)
end

Given /^there is an article posted on "([^\"]*)" with subject "([^\"]*)"$/ do |date, subject|
  Article.make!(
    received_at: date,
    subject: subject
  )
end

