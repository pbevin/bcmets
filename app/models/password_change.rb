class PasswordChange < ActiveRecord::Base
  def self.columns
    @columns ||= []
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :id, :integer
  column :old_password, :string
  column :new_password, :string

  validates_presence_of :old_password, :new_password
  validates_confirmation_of :new_password

  def old_password_correct?(user)
    user.valid_password?(old_password)
  end
end
