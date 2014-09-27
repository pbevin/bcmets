desc "Import new emails from mailing list"
task feeds: :environment do
  UpdateFeeds.run
end
