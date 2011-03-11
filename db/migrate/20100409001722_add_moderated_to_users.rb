class AddModeratedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :moderated, :boolean
  end

  def self.down
    remove_column :users, :moderated
  end
end