class Article < ActiveRecord::Base
  validates_uniqueness_of :msgid
  attr_accessor :children
  has_one :parent, :class_name => "Article", :foreign_key => "parent_id"
  belongs_to :user
  belongs_to :conversation
  before_create :start_conversation
  attr_accessor :reply_type # list, sender, or both
  attr_accessor :to
  validates_presence_of :name
  validates_presence_of :email
  validates_format_of :email,
                      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                      :message => "is not a full email address"
  validates_presence_of :subject
  validates_presence_of :body

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
    received_at > 1.month.ago
  end

  def self.for_month(year, month)
    earliest = Time.local(year, month, 1, 0, 0, 0)
    latest = 1.month.since(earliest)

    self.find(:all,
              :conditions => ["received_at >= ? and received_at < ?", earliest, latest],
              :order => "received_at DESC")
  end

  def self.link_threads
    articles_to_link = Article.find(:all, :conditions => "parent_msgid != '' and parent_id is null")
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
    self.sent_at = self.received_at = Time.now
    self.msgid = "<#{hex(16)}@bcmets.org>"
    email = TMail::Mail.new
    email.to = self.mail_to
    email.cc = self.mail_cc
    email.from = TMail::Address.special_quote_address(self.from)
    email.message_id = self.msgid
    email.in_reply_to = self.parent_msgid
    email.subject = self.subject
    email.body = self.body
    to_addrs = email.to || []
    to_addrs << email.cc unless email.cc.nil?
    puts self.inspect if email.from.nil?
    Article.send_via_smtp(email.to_s, self.email, to_addrs)
  end

  def self.send_via_smtp(msg, from, to)
    return if Rails.env.test?
    Net::SMTP::start('feste.bestiary.com', 2025) do |smtp|
      smtp.send_message msg, from, to
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
      reply.parent = self
      reply.parent_id = self.id
      reply.parent_msgid = self.msgid
      reply.body = "#{self.name} writes:\n#{quote(self.body)}"
    end
  end

  def reply?
    !to.nil?
  end

  def quote(string)
    returning "" do |body|
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
    if self.parent
      self.conversation = parent.conversation
    elsif self.parent_id
      self.conversation = Article.find_by_id(self.parent_id).conversation
    else
      self.conversation ||= Conversation.create(:title => self.subject)
    end
  end
end
