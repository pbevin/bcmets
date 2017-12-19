desc "Import new emails from mailing list"
task import_emails: [:environment] do
  ImportEmails.call!
end
