class ImportEmails
  include Interactor

  delegate :dir, to: :context

  before { context.dir ||= ENV['MAIL_IMPORT_DIR'] || "/arch" }

  def call
    recent_files.each do |file|
      Mailbox.new(file).each_message do |message|
        article = Article.parse(message)
        article.save
      end
    end
    Article.link_threads
  end

  def recent_files
    t = 6.hours.ago
    files = []
    Dir.entries(dir).each do |f|
      next unless f =~ /^[12]/
      path = File.join(dir, f)
      files << path if File.mtime(path) > t
    end
    files
  end
end
