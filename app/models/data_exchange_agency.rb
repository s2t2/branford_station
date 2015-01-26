class DataExchangeAgency < ActiveRecord::Base

  # Persists all agencies known to the gtfs data exchange.
  def self.extract_and_load!
    GTFS::DataExchange::API.agencies.each do |extracted_agency|
      begin
        raise MissingIdentifierError.new(extracted_agency[:name]) unless extracted_agency[:dataexchange_id]
        agency = DataExchangeAgency.where(
          :dataexchange_id => extracted_agency[:dataexchange_id]
        ).first_or_create
        agency.update_attributes(
          :name => extracted_agency[:name],
          :url => extracted_agency[:url],
          :dataexchange_url => extracted_agency[:dataexchange_url],
          :feed_baseurl => extracted_agency[:feed_baseurl],
          :license_url => extracted_agency[:license_url],
          :area => extracted_agency[:area],
          :state => extracted_agency[:state],
          :country => extracted_agency[:country],
          :is_official => extracted_agency[:is_official],
          :date_added => Time.at(extracted_agency[:date_added].to_i).to_datetime,
          :date_last_updated => Time.at(extracted_agency[:date_last_updated].to_i).to_datetime
        )
      rescue MissingIdentifierError => e
        puts "#{e.class -- e.message}"
        next
      end
    end
  end

  #def self.feed_publisher
  #  where("feed_baseurl IS NOT NULL")
  #end

  #def self.official
  #  where(:is_official => true)
  #end
end
