require 'machinist/active_record'
require 'faker'

def alnum(n)
  chars = ('a'..'z').to_a + ('0'..'9').to_a
  (1..n).map { chars[rand(chars.length)] }.join
end

def fake_msgid
  '<' + alnum(8) + "." + alnum(12) + "@" + Faker::Internet.domain_name + ">"
end

Article.blueprint do
  name { Faker::Name.name }
  email { Faker::Internet.email }
  subject { Faker::Lorem.sentence }
  body { Faker::Lorem.paragraph }
  received_at { Time.now }
  sent_at { Time.now }
  msgid { fake_msgid }
end

Donation.blueprint do
  email { Faker::Internet.email }
  amount { rand(490) + 10 }
  date { Time.now }
end

User.blueprint do
  name { Faker::Name.name }
  email { Faker::Internet.email }

  password { "secret" }
end
