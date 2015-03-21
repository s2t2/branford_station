namespace :station_attendant do
  desc "Extracts and loads all agencies from the GTFS Data Exchange API."
  task :find_data_exchange_feeds => :environment do
    DataExchangeExtractor.perform
  end

  desc "Extracts and loads all agencies and feeds from the Google Transit Data Feed wiki."
  task :find_google_transit_data_feeds => :environment do
    GoogleTransitDataFeedExtractor.perform
  end

  desc "Consumes feeds from known sources."
  task :consume_feeds => :environment do
    FeedConsumer.perform
  end

  desc "Finds feeds and consumes them."
  task :find_and_consume => :environment do
    DataExchangeExtractor.perform
    GoogleTransitDataFeedExtractor.perform
    FeedConsumer.perform(:transit_data_feed => true, :data_exchange => true)
  end

  desc "Finds feeds and consumes them and loads them."
  task :find_and_consume_and_load => :environment do
    DataExchangeExtractor.perform
    GoogleTransitDataFeedExtractor.perform
    FeedConsumer.perform(:transit_data_feed => true, :data_exchange => true, :load => true)
  end
end
