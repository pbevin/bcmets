
require 'article_parser'


def each_message(mbox_filename)
  starting = true
  article = ''
  File.open(mbox_filename) do |file|
    file.each_line do |line|
      if line =~ /^From (.*)/
        if !starting
          yield article
          article = ''
        end
        starting = false
      end
      article += line
    end
  end
  yield article unless starting
end

def parse(text)
  returning Article.new do |article|
    parser = ArticleParser.new(article)
    for line in text.lines
      parser << line.strip
    end
  end
end

def recent_files
  dir = "/home/mets/arch"
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
task :import_emails do
  for file in recent_files
    each_message(file) do |message|
      article = parse(message)
      article.save
    end
  end
  Article.link_threads
end