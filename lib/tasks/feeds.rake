desc "Import new emails from mailing list"
task feeds: :environment do
  Feed.update_all
end
