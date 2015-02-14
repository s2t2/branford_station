namespace :station_attendant do
  desc "Extracts and loads all agencies from the GTFS Data Exchange API."
  task extract_from_data_exchange: :environment do
    DataExchangeExtractor.perform
  end

  desc "Extracts and loads all agencies and feeds from the Google Transit Data Feed wiki."
  task :extract_from_google_transit_data_feed => :environment do
    GoogleTransitDataFeedExtractor.perform
  end

  desc "Extracts feed files from all known sources."
  task :extract_feed_files => :environment do
    FeedFileExtractor.perform
  end
end
