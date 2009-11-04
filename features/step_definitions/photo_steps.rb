Then /^(.+) should have an attached photo$/ do |who|
  user = model(who)
  user.photo.should be_present
end
