class EventLog < ActiveRecord::Base
  attr_accessible :email, :reason, :message
end
