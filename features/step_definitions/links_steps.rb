Given(/^there are no links$/) do
  Link.destroy_all
end

Then(/^a link should exist with #{capture_fields}$/) do |attrs|
  Link.where(parse_fields(attrs)).count.should == 1
end
