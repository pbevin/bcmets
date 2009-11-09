class CreateEventLogs < ActiveRecord::Migration
  def self.up
    create_table :event_logs do |t|
      t.string :email
      t.string :reason
      t.text :message

      t.timestamps
    end
  end

  def self.down
    drop_table :event_logs
  end
end
