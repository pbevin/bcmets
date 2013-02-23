def recent_files
  dir = ENV['MAIL_IMPORT_DIR'] || "/home/mets/arch"
  t = 30.minutes.ago
  files = []
  Dir.entries(dir).each do |f|
    next unless f =~ /^[12]/
    path = File.join(dir, f)
    files << path if File.mtime(path) > t
  end
  files
end

desc "Import new emails from mailing list"
task :import_emails => [:environment] do
  for file in recent_files
    Mailbox.new(file).each_message do |message|
      article = Article.parse(message)
      article.save
    end
  end
  Article.link_threads
end
