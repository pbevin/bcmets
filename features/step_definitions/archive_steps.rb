Given(/^an article exists with #{capture_fields}$/) do |attrs|
  @article = Article.make! parse_fields(attrs)
end

Given(/^there are no articles$/) do
  Article.destroy_all
end

Given(/^an article exists$/) do
  @article = Article.make!
end

When(/^I fill in the fake article body with "(.*?)"$/) do |spam|
  fill_in "article_body", visible: false, with: spam
end
