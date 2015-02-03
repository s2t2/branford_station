namespace :station_attendant do
  desc "Extracts and loads all agencies from the GTFS Data Exchange API."
  task extract_and_load_data_exchange: :environment do
    DataExchangeExtractor.perform
  end

  desc "Extracts and loads all agencies and feeds from the Google Transit Data Feed wiki."
  task :extract_and_load_google_transit_data_feed => :environment do
    GoogleTransitDataFeedExtractor.perform
  end
end
