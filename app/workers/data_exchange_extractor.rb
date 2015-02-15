require 'gtfs_data_exchange_api'

class DataExchangeExtractor

  # Extracts and loads all agencies from the GTFS Data Exchange API.

  def self.perform
    data_exchange_agencies = GTFSDataExchangeAPI.agencies
    data_exchange_agencies.each do |extracted_agency|
      unless extracted_agency[:dataexchange_id]
        puts "Agency #{extracted_agency[:name]} is missing an identifier."
        next
      end

      agency = DataExchangeAgency.where(
        :dataexchange_id => extracted_agency[:dataexchange_id]
      ).first_or_create
      agency.update_attributes(
        :name => extracted_agency[:name]
      )
    end
  end
end
