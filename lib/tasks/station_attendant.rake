namespace :station_attendant do
  desc "Extracts and loads all agencies from the gtfs data exchange."
  task extract_and_load_data_exchange_agencies: :environment do
    DataExchangeAgency.extract_and_load!
  end

  desc "Extracts and loads all public feeds from the google transit data feed wiki."
  task :extract_and_load_google_transit_data_feed_public_feeds => :environment do
    GoogleTransitDataFeedPublicFeed.extract_and_load!
  end
end
