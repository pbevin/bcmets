Before do
  ApplicationController.class_eval do
    def logged_in_as_admin
      true
    end
  end
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
