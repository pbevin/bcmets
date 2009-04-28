class Article < ActiveRecord::Base
  validates_uniqueness_of :msgid
  attr_accessor :children
  has_one :parent, :class_name => "Article", :foreign_key => "parent_id"
  attr_accessor :reply_type # list, sender, or both
  attr_accessor :to
  validates_presence_of :name
  validates_presence_of :email
  validates_presence_of :subject
  validates_presence_of :body
  
  define_index do
    indexes name, email, subject, body
  end
  
  def from
    if name == email
      return email
    else
      return name + " <" + email + ">"
    end
  end
  
  def recent?
    received_at > 1.month.ago
  end
  
  def self.for_month(year, month)
    earliest = Time.local(year, month, 1, 0, 0, 0)
    latest = 1.month.since(earliest)
    
    self.find(:all,
              :conditions => ["received_at >= ? and received_at < ?", earliest, latest],
              :order => "received_at DESC")
  end

  def self.parse(text)
    returning Article.new do |article|
      # From bcmets-bounces@bcmets.org  Thu Mar 12 21:33:32 2009
      from_line = text.lines.first
      received_time = parse_from_line(from_line)
      article.received_at = Time.zone.parse(received_time)
      
      header_text, body = text.split(/\n\n/, 2)
      headers = parse_rfc2822_headers(header_text)
      
      # Date: Thu, 12 Mar 2009 21:33:26 -0400 (EDT)
      if headers['Date']
        article.sent_at = DateTime.parse(headers['Date']).to_time
      end
      
      # From: Pete Bevin <pete@petebevin.com>
      from = headers['From']
      article.name, article.email = parse_sender(from)
      
      article.subject = (headers['Subject'] || '').gsub(/\[.*\] ?/, '')
      article.msgid = headers['Message-Id'] || headers['Message-ID'] || headers['Message-id']
      parent_msgid = headers['In-Reply-To']
      if parent_msgid != '<>'
        article.parent_msgid = parent_msgid
      end
      article.body = body
    end
  end
  
  def self.link_threads
    articles_to_link = Article.find(:all, :conditions => "parent_msgid != '' and parent_id is null")
    articles_to_link.each do |article|
      parent = Article.find_by_msgid(article.parent_msgid)
      if parent != nil
        article.parent_id = parent.id
      end
      article.save
    end
  end
  
  def self.thread_tree(unthreaded)
    hash = unthreaded.index_by(&:id)
    
    retval = []
    for article in unthreaded
      if article.parent_id.nil? || !hash.has_key?(article.parent_id)
        retval << article
      else
        parent = hash[article.parent_id]
        parent.children ||= []
        parent.children << article
      end
    end
    
    return retval
  end
  
  def self.parse_sender(from)
    if from =~ /(.*) <(.*)>/
      return $1, $2
    elsif from =~ /^<(.*)>$/
      return $1, $1
    else
      return from, from
    end
  end
  
  def self.parse_rfc2822_headers(header_text)
    returning Hash.new do |headers|
      matches = header_text.scan(/^([^:]*): (.*(?:\n\s+.*)*)/)
      matches.each { |a,b| headers[a] = b }
    end  
  end
  
  def self.parse_from_line(from_line)
    from_line.sub(/.*?  /, '')
  end
  
  def prepare_for_email
    self.sent_at = self.received_at = Time.now
    self.msgid = "<#{hex(16)}@bcmets.org>"
  end
  
  def hex(n)
    f = File.open("/dev/random", "rb")
    hexCode = r.read(n/2).unpack("H*")
    f.close
    hexCode
  end
  
  def send_via_email
    if $list_address == nil
      raise "Can't send email in test environment"
    end
    email = TMail::Mail.new
    email.to = self.mail_to
    email.cc = self.mail_cc
    email.from = self.from
    email.message_id = self.msgid
    email.subject = self.subject
    email.body = self.body
    Net::SMTP::start('feste.bestiary.com', 2025) do |smtp|
      to_addrs = email.to || []
      to_addrs << email.cc unless email.cc.nil?
      smtp.send_message email.to_s, email.from.first, to_addrs
    end
  end
  
  def mail_to
    if reply_type == 'sender'
      self.to
    else
      $list_address
    end
  end
  
  def mail_cc
    if reply_type == 'both'
      self.to
    else
      ''
    end
  end

  def reply
    returning Article.new do |reply|
      reply.reply_type = self.reply_type
      reply.subject = self.subject
      reply.subject = "Re: #{reply.subject}" unless reply.subject =~ /^Re:/i
      reply.to = self.from
      reply.parent_id = self.id
      reply.parent_msgid = self.msgid
      reply.body = "#{self.name} writes:\n#{quote(self.body)}"
    end
  end
  
  def reply?
    !to.nil?
  end
  
private

  def quote(string)
    returning "" do |body|
      wrap(string).each { |line| body << "> #{line}\n" }
    end
  end

  def wrap(text, columns = 72)
    text.split("\n").collect do |line|
     line.length > columns ? line.gsub(/(.{1,#{columns}})(\s+|$)/, "\\1\n").strip : line
    end
  end
end
