Given(/^(\d+) recent articles$/) do |count|
  count.to_i.times do
    Article.make!(user: User.make!)
  end
end

When(/^I view the timeline$/) do
  visit "/timeline"
end

Then(/^I should see (\d+) articles$/) do |count|
  expect(all(".tl_post").count).to eq(count.to_i)
end
