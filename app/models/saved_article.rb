class SavedArticle < ActiveRecord::Base
  def self.primary_key; :id end # Rails 4.2: https://github.com/makandra/active_type/issues/31
  belongs_to :user
  belongs_to :article
end
