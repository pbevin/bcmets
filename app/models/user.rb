require 'maxmind'

class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = :email
    c.validates_length_of_password_field_options = {:on => :update, :minimum => 4, :if => :has_no_credentials?}
    c.validates_length_of_password_confirmation_field_options = {:on => :update, :minimum => 4, :if => :has_no_credentials?}
  end
  
  validates_presence_of :name
  attr_protected :active
  has_attached_file :photo, :processors => [:cropper], :styles => {
    :small => "100x100#",
    :medium => "300x300>",
    :large => "500x500>"
  }
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_photo, :if => :cropping?

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def has_no_credentials?
    self.crypted_password.blank?
  end

  def signup!
    save_without_session_maintenance
  end

  def activate!
    self.active = true
    save
  end
  
  def has_photo?
    @photo.present?
  end

  def guess_location(ip_addr)
    self.location = MaxMind::lookup(ip_addr) unless self.location && self.location != ""
  end
  
  def active?
    active
  end

  def deliver_activation_instructions!
    reset_perishable_token!
    Notifier.deliver_activation_instructions(self)
  end

  def deliver_activation_confirmation!
    reset_perishable_token!
    Notifier.deliver_activation_confirmation(self)
  end
  
  def log_activation
    EventLog.create!(:email => self.email,
                     :reason => "signup",
                     :message => "Mode = #{self.email_delivery}, name = #{self.name}, id = #{self.id}")
  end

  def reset_password!
    reset_perishable_token!
    Notifier.deliver_password_reset(self)
  end

  def update_mailman
    system("/home/mailman/delivery", "bcmets", email, email_delivery) if active? and email_delivery
  end

  def photo_geometry(style = :original)  
    @geometry ||= {}  
    @geometry[style] ||= Paperclip::Geometry.from_file(photo.path(style))  
  end
  
  private  
  def reprocess_photo
    photo.reprocess!
  end
end
