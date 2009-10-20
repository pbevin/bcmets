require 'faker'

def alnum(n)
  chars = ('a'..'z').to_a + ('0'..'9').to_a 
  (1..n).map { chars.rand }.to_s
end

Sham.name  { Faker::Name.name }
Sham.email { Faker::Internet.email }
Sham.subject { Faker::Lorem.sentence }
Sham.body  { Faker::Lorem.paragraph }
Sham.date { Time.gm(2009, "Mar", rand(20) + 5, rand(24), rand(60), rand(60)) }
Sham.msgid { '<' + alnum(8) + "." + alnum(12) + "@" + Faker::Internet.domain_name + ">" }
Sham.amount { rand(490) + 10 }

Article.blueprint do
  name
  email
  subject
  body
  received_at { Sham.date }
  sent_at { Sham.date }
  msgid { Sham.msgid }
end

Donation.blueprint do
  email
  amount
  date
end

User.blueprint do
  name
  email
  
  password { "secret" }
end