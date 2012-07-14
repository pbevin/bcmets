class CreateSavedArticles < ActiveRecord::Migration
  def self.up
    create_table :saved_articles, :id => false do |t|
      t.integer :user_id
      t.integer :article_id
    end
  end

  def self.down
    drop_table :saved_articles
  end
end
