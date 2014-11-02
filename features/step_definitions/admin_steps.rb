Before do
  u = User.create(email: "pete@petebevin.com",
                  name: "Pete Bevin",
                  password: "123456",
                  email_delivery: "none",
                  created_at: "1969-12-30")
  u.activate!
  u.save!
end

When /^I login as administrator$/ do
  visit "/login"
  fill_in("Email", with: "pete@petebevin.com")
  fill_in("Password", with: "123456")
  click_button("Login")
end

def table_at(selector)
  Nokogiri::HTML(page.body).css(selector).map do |table|
    table.css('tr').map do |tr|
      tr.css('td, th').map(&:text)
    end
  end[0].reject(&:empty?)
end

Then /^I should see users table$/ do |table|
  html_table = table_at("#users").to_a
  html_table.each { |row| row.pop if row.length == 4 } # delete last column
  table.diff!(html_table)
end

When /^I delete the first user$/ do
  find("#users tbody tr:first-child").click_link("D")
end
