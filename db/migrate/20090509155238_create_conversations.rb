class CreateConversations < ActiveRecord::Migration
  def self.up
    create_table :conversations do |t|
      t.string :title

      t.timestamps
    end
    
    add_column :articles, :conversation_id, :integer
  end

  def self.down
    drop_table :conversations
    remove_column :articles, :conversation_id
  end
end
