ThinkingSphinx::Index.define :article, :with => :active_record do
  indexes name, email, subject, body
  indexes received_at, :sortable => true
end
