require 'article_parser'

class Article < ActiveRecord::Base
  validates_uniqueness_of :msgid
  attr_accessor :children
  has_one :parent, :class_name => "Article", :foreign_key => "parent_id"
  belongs_to :user
  belongs_to :conversation
  before_create :start_conversation
  before_create :determine_user
  attr_accessor :reply_type # list, sender, or both
  attr_accessor :to
  validates_presence_of :name
  validates_presence_of :email
  validates_format_of :email,
                      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                      :message => "is not a full email address"
  validates_presence_of :subject
  validates_presence_of :body

  attr_accessible :name, :email, :body, :qt, :subject, :msgid
  attr_accessible :parent_msgid, :parent_id, :reply_type
  attr_accessible :content_type, :to, :sent_at

  attr_accessor :qt  # honeytrap for body field

  define_index do
    indexes name, email, subject, body
    indexes received_at, :sortable => true
  end

  def from
    if name == email
      return email
    else
      return name + " <" + email + ">"
    end
  end

  def recent?
    (received_at || created_at) > 1.month.ago
  end

  def saved_by?(user)
    return false if !user
    user.saved?(self)
  end

  def sent_at_human
    sent_at_date = sent_at.strftime("%b %d, %Y")
    today_date = Time.now.strftime("%b %d, %Y")

    if sent_at_date == today_date
      sent_at.strftime("%H:%M %p")
    else
      sent_at_date
    end
  end

  def self.for_month(year, month, order = "received_at ASC")
    earliest = Time.local(year, month, 1, 0, 0, 0)
    latest = 1.month.since(earliest)

    where(:received_at => (earliest..latest)).order(order)
  end

  def self.link_threads(since=6.months.ago)
    articles_to_link = Article.all(:conditions => ["parent_msgid != '' and parent_id is null and created_at > ?", since])
    articles_to_link.each do |article|
      parent = Article.find_by_msgid(article.parent_msgid)
      if parent != nil
        article.parent_id = parent.id
        if article.conversation.nil?
          article.conversation = parent.conversation
        else
          Article.update_all(["conversation_id = ?", parent.conversation],
                             ["conversation_id = ?", article.conversation])
        end
      end
      article.save
    end
  end

  def self.thread_tree(unthreaded)
    hash = unthreaded.index_by(&:id)

    retval = []
    unthreaded.each do |article|
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

  def each_child(&block)
    return if children.nil?
    children.each do |child|
      yield child
      child.each_child(&block)
    end
  end

  def hex(n)
    SecureRandom::hex(n/2)
  end

  def send_via_email
    self.sent_at = self.received_at = Time.zone.now
    self.msgid = "<#{hex(16)}@bcmets.org>"

    mail = Notifier.article(self)
    #mail.message_id = msgid
    mail.deliver
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

  def charset
    return "utf-8" if content_type.blank?

    if content_type =~ /charset="(.*?)"/
      return $1
    elsif content_type =~ /charset=(\S+)/
      return $1
    else
      return "utf-8"
    end
  end

  def body_utf8
    body.force_encoding(charset)
    body.force_encoding("CP1252") if !body.valid_encoding?
    body.encode("UTF-8")
  end

  def reply
    Article.new.tap do |reply|
      reply.reply_type = self.reply_type
      reply.subject = self.subject
      reply.subject = "Re: #{reply.subject}" unless reply.subject =~ /^Re:/i
      reply.to = self.from
      reply.parent = self
      reply.parent_id = self.id
      reply.parent_msgid = self.msgid
      reply.body = "#{self.name} writes:\n#{quote(self.body_utf8)}"
    end
  end

  def reply?
    !to.nil?
  end

  def quote(string)
    "".tap do |body|
      lines = wrap(string).collect{|line| line.split("\n")}.flatten
      lines.each { |line| body << "> #{line}\n" }
    end
  end

  def wrap(text, columns = 72)
    text.split("\n").collect do |line|
     line.length > columns ? line.gsub(/(.{1,#{columns}})(\s+|$)/, "\\1\n").strip : line
    end
  end

  def start_conversation
    if parent
      self.conversation = parent.conversation
    elsif parent_id
      self.conversation = Article.find_by_id(self.parent_id).conversation
    else
      self.conversation ||= Conversation.create(:title => self.subject)
    end
  end

  def determine_user
    self.user ||= User.find_by_email(email)
  end

  def self.parse(text)
    article = Article.new
    parser = ArticleParser.new(article)
    for line in text.lines
      parser << line.strip
    end
    return article
  end
end
