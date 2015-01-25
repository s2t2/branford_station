namespace :station_attendant do
  desc "extracts agencies from the data exchange"
  task extract_and_load_data_exchange_agencies: :environment do
    DataExchangeAgency.extract_and_load!
  end
end
