Then /^the user should have an attached photo$/ do
  @user.reload.photo.should be_present
end
