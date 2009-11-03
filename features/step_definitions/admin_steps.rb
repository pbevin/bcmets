Before do
  u = User.create(:email => "pete@petebevin.com",
                  :name => "Pete Bevin",
                  :password => "123456",
                  :email_delivery => "none",
                  :created_at => "1969-12-30")
  u.activate!
  u.save!
end

When /^I login as administrator$/ do
  visit "/login"
  fill_in("Email", :with => "pete@petebevin.com")
  fill_in("Password", :with => "123456")
  click_button("Login")
end

Then /^I should see users table$/ do |table|
  html_table = table_at("#users").to_a
  html_table.map! { |r| r.map! { |c| c.gsub(/&lt;/, "<").gsub(/&gt;/, ">") } }
  table.diff!(html_table)
end

Given /^#{capture_model} is( not)? active$/ do |name, not_active|
  user = model(name)
  user.active = !not_active
  user.save!
end
