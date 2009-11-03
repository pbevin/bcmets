require 'maxmind'

class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.login_field = :email
    c.validates_length_of_password_field_options = {:on => :update, :minimum => 4, :if => :has_no_credentials?}
    c.validates_length_of_password_confirmation_field_options = {:on => :update, :minimum => 4, :if => :has_no_credentials?}
  end
  
  validates_presence_of :name
  attr_protected :active

  after_save :update_mailman

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
  
  def reset_password!
    reset_perishable_token!
    Notifier.deliver_password_reset(self)
  end

  private

  def update_mailman
    system("/home/mailman/delivery", "bcmets", email, email_delivery) if active? and email_delivery
  end
end
