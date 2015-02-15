require 'zip'

class FeedConsumer
  FEED_FILE_NAMES = ["agency.txt","stops.txt","routes.txt","trips.txt","stop_times.txt","calendars.txt","calendar_dates.txt","shapes.txt","fare_attributes.txt","fare_rules.txt","frequencies.txt","transfers.txt"]

  def self.gtfs_data_directory
    "gtfs"
  end

  # Extract feed files from source.
  #
  # @examples
  #    FeedConsumer.perform(:source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"])
  #    FeedConsumer.perform
  #
  # @param [Hash] options
  # @option options [Array] :source_urls ([])
  # @option options [boolean] :transit_data_feed (false) Whether or not to include sources from the google transit data feed.
  # @option options [boolean] :data_exchange (false) Whether or not to include sources from the data exchange.
  # @option options [boolean] :load_strategy ("filesystem") Where to download gtfs source ("filesystem" or "database")?
  #
  def self.perform(options = {})
    load_strategy = options[:load_strategy] || "filesystem"
    transit_data_feed_request = options[:transit_data_feed] || false
    data_exchange_request = options[:data_exchange] || false
    source_urls = options[:source_urls] || []

    source_urls += DataExchangeAgency.pluck(:feed_baseurl) if data_exchange_request == true
    source_urls += GoogleTransitDataFeedPublicFeed.pluck(:url) if transit_data_feed_request == true
    source_urls = source_urls.compact.uniq.select{|url| url.ends_with?(".zip")}
    puts "IDENTIFIED #{source_urls.length} SOURCES"

    source_urls.each do |source_url|
      begin

        # Parse source url.

        uri = URI.parse(source_url)
        feed_host_name = uri.host
        feed_name = uri.path.split("/").last
        puts uri

        next unless feed_host_name && feed_name
        feed_host = FeedHost.where(:name => feed_host_name).first_or_create
        feed = Feed.where(
          :source_url => source_url,
          :host_id => feed_host.id
        ).first_or_create!
        feed.update_attributes!(:name => feed_name)

        # Request information about the latest source version.

        next unless uri.scheme == "http"
        response = Net::HTTP.get_response(uri)

        response_header = response.to_hash
        pp "=> #{response_header}"

        next unless response_header
        last_modified_at = response_header["last-modified"].try(:first).try(:to_datetime)

        next unless last_modified_at && last_modified_at.is_a?(DateTime)
        version = FeedVersion.where(
          :feed_id => feed.id,
          :last_modified_at => last_modified_at
        ).first_or_create!
        version.update_attributes!(
          :last_checked_at => Time.zone.now,
          :response_code => response.code.to_i,
          :response_message => response.message.to_s,
          :accept_ranges => response_header["accept-ranges"],
          :cache_control => response_header["cache-control"],
          :connection => response_header["connection"],
          :content_type => response_header["content-type"],
          :content_language => response_header["content-language"],
          :content_length => response_header["content-length"],
          :etag => response_header["etag"],
          :expires => response_header["expires"].try(:first).try(:to_datetime),
          :server => response_header["server"],
          :x_powered_by => response_header["x-powered-by"],
          :set_cookie => response_header["set-cookie"]
        )

        # Load the latest source version.

        case load_strategy
        when "filesystem"

          # Download feed files.

          destination_path = "#{gtfs_data_directory}/hosts/#{feed_host_name}/feeds/#{feed_name}/versions/#{last_modified_at}"
          FileUtils.mkdir_p(destination_path)

          zip_file_name = feed_name
          zip_file_path = "#{destination_path}/#{zip_file_name}"
          File.open(zip_file_path, "wb") do |zip_file|
            zip_file.write response.body
          end

          Zip::File.open(zip_file_path) do |zip_file|
            zip_file.each do |entry|
              entry_name = entry.name
              next unless FEED_FILE_NAMES.include?(entry_name)
              txt_file_path = "#{destination_path}/#{entry_name}"
              next if File.exist?(txt_file_path)
              entry.extract(txt_file_path)
            end
          end

        when "database"

          # Load feed txt files.

          # agencies          => FeedVersionAgency        => AgencyVersion        => Agency
          # calendar_dates    => FeedVersionCalendarDate  => CalendarDateVersion  => CalendarDate
          # fare_attributes   => FeedVersionFareAttribute => FareAttributeVersion => FareAttribute
          # fare_rules        => FeedVersionFareRule      => FareRuleVersion      => FareRule
          # routes            => FeedVersionRoute         => RouteVersion         => Route
          # shapes            => FeedVersionShape         => ShapeVersion         => Shape
          # stop_times        => FeedVersionStopTime      => StopTimeVersion      => StopTime
          # stops             => FeedVersionStop          => StopVersion          => Stop
          # trips             => FeedVersionTrip          => TripVersion          => Trip

          binding.pry

          #source = GTFS::Source.build(response.body, {strict: false})

        end
      rescue => e
        puts "#{e.class} -- #{e.message}"
      end
    end

    system "say 'process managed'" if Rails.env == "development"
  end
end
