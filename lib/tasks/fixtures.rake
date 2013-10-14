require 'faker'

desc "Create fake articles for testing"
task :fixtures => [:environment] do
  people = []
  50.times do
    frequency = 2**rand(6)
    people += [ OpenStruct.new(name: Faker::Name.name, email: Faker::Internet.email) ] * frequency
  end
  articles = []
  500.times do |n|
    person = people.sample

    if n > 20 && rand(10) < 8
      parent = articles.sample
      sent_at = parent.sent_at + rand(8*3600).seconds

      if rand(100) < 8
        subject = random_subject
      elsif parent.subject.starts_with?("Re:")
        subject = parent.subject
      else
        subject = "Re: " + parent.subject
      end
    else
      parent = nil
      sent_at = Time.now - rand(1e6).seconds
      subject = random_subject
      subject = "Fwd: #{subject}" if rand(20) == 0
    end
    received_at = sent_at + rand(100).seconds
    body = Faker::Lorem.paragraphs(rand(7) + 1).join("\n\n") + "\n\n" + person.name + "\n"

    article = Article.create!(
      sent_at: sent_at,
      name: person.name,
      email: person.email,
      subject: subject,
      body: body
    ) do |article|
      article.parent_msgid = parent.try(:msgid)
      article.received_at = received_at
      article.msgid = SecureRandom.hex(8) + "@bcmets.org"
    end

    articles << article

    puts "#{article.id}: #{article.sent_at.to_s(:db)} - #{article.subject}"
  end
  Article.link_threads
end

def random_subject
  Faker::Lorem.words(3 + rand(6)).join(" ")
end
