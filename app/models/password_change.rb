class PasswordChange
  include ActiveModel::Model

  attr_accessor :id, :old_password, :new_password

  validates_presence_of :old_password, :new_password
  validates_confirmation_of :new_password

  def old_password_correct?(user)
    user.valid_password?(old_password)
  end
end
