Then(/^an event log should exist with #{capture_fields}$/) do |attrs|
  fields = parse_fields(attrs)
  EventLog.where(fields).count.should == 1
  @event = EventLog.find_by(fields)
end

Then(/^the event log should be in the user's events$/) do
  @user.events.should include(@event)
end
