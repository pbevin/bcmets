class Conversation < ActiveRecord::Base
  has_many :articles
end
