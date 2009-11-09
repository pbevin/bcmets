class AddUserIdToEventLogs < ActiveRecord::Migration
  def self.up
    add_column :event_logs, :user_id, :integer
  end

  def self.down
    remove_column :event_logs, :user_id
  end
end
