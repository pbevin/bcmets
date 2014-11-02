class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = :email
    c.transition_from_crypto_providers = Authlogic::CryptoProviders::Sha512
    c.validates_length_of_password_field_options = { on: :update, minimum: 4, if: :has_no_credentials? }
    c.validates_length_of_password_confirmation_field_options = { on: :update, minimum: 4, if: :has_no_credentials? }
  end

  validates_presence_of :name

  has_attached_file :photo, processors: [:cropper], styles: {
    small: "100x100#",
    medium: "300x300>",
    large: "500x500>"
  }
  validates_attachment :photo,
                       content_type: { content_type: %r{\Aimage} },
                       size: { in: 0..1.megabyte }

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_photo, if: :cropping?

  has_many :events, class_name: "EventLog"
  has_and_belongs_to_many :saved_articles,
                          join_table: "saved_articles", class_name: "Article"

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def has_no_credentials?
    crypted_password.blank?
  end

  def signup!
    save_without_session_maintenance
  end

  def activate!
    self.active = true
    save
  end

  def admin?
    email == 'pete@petebevin.com'
  end

  def has_photo?
    @photo.present?
  end

  def active?
    active
  end

  def deliver_activation_instructions!
    reset_perishable_token!
    Notifier.activation_instructions(self).deliver
  end

  def deliver_activation_confirmation!
    reset_perishable_token!
    Notifier.activation_confirmation(self).deliver
  end

  def log_activation
    events << EventLog.new(email: email,
                           reason: "signup",
                           message: "Mode = #{email_delivery}, name = #{name}")
  end

  def secret_key
    Digest::SHA1.hexdigest(crypted_password.to_s + email)
  end

  def reset_password!
    reset_perishable_token!
    Notifier.password_reset(self).deliver
  end

  # alias :orig_system :system
  #
  # def system(*args)
  #   p args.join(" ")
  #   orig_system(*args)
  # end

  def update_mailman
    as_mailman("/home/mailman/delivery", "bcmets", email, email_delivery) if active? && email_delivery
  end

  def delete_from_mailman
    as_mailman("/home/mailman/bin/remove_members", "--nouserack", "--noadminack", "bcmets", email)
  end

  def as_mailman(*args)
    system("sudo", "-u", "mailman", *args) if Rails.env.production?
  end

  def photo_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(photo.path(style))
  end

  def save_article(article)
    saved_articles << article
  end

  def unsave_article(article)
    saved_articles.delete(article)
  end

  def saved?(article)
    saved_articles.inspect if !saved_articles.loaded? # get the association cached
    saved_articles.include?(article)
  end

  private

  def reprocess_photo
    photo.reprocess!
  end
end
