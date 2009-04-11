class Article < ActiveRecord::Base
  validates_uniqueness_of :msgid
  attr_accessor :children
  has_one :parent, :class_name => "Article", :foreign_key => "parent_id"
  
  def from
    if name == email
      return email
    else
      return name + " <" + email + ">"
    end
  end
  
  def self.for_month(year, month)
    earliest = Time.local(year, month, 1, 0, 0, 0)
    latest = Time.local(year, month + 1, 1, 0, 0, 0)
    
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
    articles_to_link = Article.find(:all, :conditions => "parent_msgid != ''")
    articles_to_link.each do |article|
      article.parent_id = Article.find_by_msgid(article.parent_msgid).id
      article.save
    end
  end
  
  def self.thread_tree(unthreaded)
    hash = {}
    for article in unthreaded
      hash[article.id] = article
    end
    
    retval = []
    for article in unthreaded
      if article.parent_id.nil? || !hash.has_key?(article.parent_id)
        retval << article
      else
        parent = hash[article.parent_id]
        parent.children ||= []
        hash[article.parent_id].children << article
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
end
