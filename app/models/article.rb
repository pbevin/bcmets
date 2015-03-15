require 'article_parser'

class Article < ActiveRecord::Base
  validates_uniqueness_of :msgid
  attr_accessor :children
  belongs_to :parent, class_name: "Article", foreign_key: "parent_id"
  belongs_to :user
  belongs_to :conversation
  before_create :start_conversation
  before_create :determine_user
  attr_accessor :reply_type # list, sender, or both
  attr_accessor :to
  validates_presence_of :name
  validates_presence_of :email
  validates_format_of :email,
                      with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                      message: "is not a full email address"
  validates_presence_of :subject
  validates_presence_of :body

  attr_accessor :qt  # honeytrap for body field

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
    return false if user.nil?
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

    where(received_at: (earliest..latest)).order(order)
  end

  def self.link_threads(since = 6.months.ago)
    LinkThreads.run(since)
  end

  def self.thread_tree(unthreaded)
    hash = unthreaded.index_by(&:id)

    top_level_articles = []
    unthreaded.each do |article|
      if article.parent_id.nil? || !hash.key?(article.parent_id)
        top_level_articles << article
      else
        parent = hash[article.parent_id]
        parent.children ||= []
        parent.children << article
      end
    end

    top_level_articles
  end

  def each_child(&block)
    return if children.nil?
    children.each do |child|
      yield child
      child.each_child(&block)
    end
  end

  def random_msgid
    random = SecureRandom.urlsafe_base64(12)
    "<#{random}@bcmets.org>"
  end

  def send_via_email
    self.sent_at = self.received_at = Time.zone.now
    self.msgid = random_msgid

    Notifier.article(self).deliver
  end

  def mail_to
    if reply_type == 'sender'
      to
    else
      Rails.configuration.list_address
    end
  end

  def mail_cc
    if reply_type == 'both'
      to
    else
      ''
    end
  end

  def charset
    return "utf-8" if content_type.blank?

    if content_type =~ /charset="(.*?)"/
      return $1
    elsif content_type =~ /charset=([^;,\s]+)/
      return $1
    else
      return "utf-8"
    end
  end

  def body_utf8
    CharsetFixer.new(charset).fix(body)
  end

  def reply
    Reply.create_from(self)
  end

  def reply?
    parent_id.present?
  end

  def start_conversation
    if parent
      self.conversation = parent.conversation
    elsif parent_id
      self.conversation = Article.find_by_id(parent_id).conversation
    elsif maybe_parent = Article.find_by_msgid(parent_msgid)
      self.conversation = maybe_parent.conversation
    else
      self.conversation ||= Conversation.create(title: subject)
    end
  end

  def determine_user
    self.user ||= User.find_by_email(email)
  end

  def self.parse(text)
    article = Article.new
    parser = ArticleParser.new(article)
    text.lines.each do |line|
      parser << line.strip
    end
    parser.save
    article
  end
end
