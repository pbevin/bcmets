class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.datetime :sent_at
      t.datetime :received_at
      t.string :name
      t.string :email
      t.string :subject
      t.text :body
      t.string :msgid
      t.string :parent_msgid
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
