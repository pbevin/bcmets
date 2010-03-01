class SetArticleUsers < ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      Article.update_all(["user_id = ?", user.id], ["email = ? and user_id is null", user.email])
    end
  end

  def self.down
  end
end
