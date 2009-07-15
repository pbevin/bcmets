class AddLegacyId < ActiveRecord::Migration
  def self.up
    add_column(:articles, :legacy_id, :string)
  end

  def self.down
    remove_column(:articles, :legacy_id)
  end
end
