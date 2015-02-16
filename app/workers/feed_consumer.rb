require 'zip'

class FeedConsumer
  FEED_FILE_NAMES = ["agency.txt","stops.txt","routes.txt","trips.txt","stop_times.txt","calendars.txt","calendar_dates.txt","shapes.txt","fare_attributes.txt","fare_rules.txt","frequencies.txt","transfers.txt"]

  def self.gtfs_data_directory
    "gtfs"
  end

  # Extract feed files from source.
  #
  # @examples
  #    FeedConsumer.perform(:data_exchange => true)
  #    FeedConsumer.perform(:source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"])
  #    FeedConsumer.perform
  #
  # @param [Hash] options
  # @option options [Array] :source_urls ([])
  # @option options [boolean] :transit_data_feed (false) Whether or not to include sources from the google transit data feed.
  # @option options [boolean] :data_exchange (false) Whether or not to include sources from the data exchange.
  # @option options [boolean] :load_strategy ("filesystem") How to download gtfs source: "filesystem" or "database"? Both will download feed files, but the "database" option will also load file contents into the database.
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
        response = nil
        http = Net::HTTP.start(uri.host)
        response_head = http.head(uri.path)
        response_header = response_head.to_hash
        pp response_header

        next unless response_header
        last_modified_at = response_header["last-modified"].try(:first).try(:to_datetime)

        next unless last_modified_at && last_modified_at.is_a?(DateTime)
        version = FeedVersion.where(
          :feed_id => feed.id,
          :last_modified_at => last_modified_at
        ).first_or_create!
        version.update_attributes!(
          :last_checked_at => Time.zone.now,
          :response_code => response_head.code.to_i,
          :response_message => response_head.message.to_s,
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

        # Extract and load gtfs source.

        case load_strategy
        when "filesystem"

          # Download feed files.

          response = Net::HTTP.get_response(uri)

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

          # Load feed files into database.

          # agencies          => FeedVersionAgency        (AgencyVersion?)        => Agency
          # calendar_dates    => FeedVersionCalendarDate  (CalendarDateVersion?)  => CalendarDate
          # fare_attributes   => FeedVersionFareAttribute (FareAttributeVersion?) => FareAttribute
          # fare_rules        => FeedVersionFareRule      (FareRuleVersion?)      => FareRule
          # routes            => FeedVersionRoute         (RouteVersion?)         => Route
          # shapes            => FeedVersionShape         (ShapeVersion?)         => Shape
          # stop_times        => FeedVersionStopTime      (StopTimeVersion?)      => StopTime
          # stops             => FeedVersionStop          (StopVersion?)          => Stop
          # trips             => FeedVersionTrip          (TripVersion?)          => Trip

          source = GTFS::Source.build(source_url, {strict: false})

          binding.pry

          agencies = source.agencies
          agencies.each do |agency|
            puts agency
            #<GTFS::Agency:0x007f956c0c5ab8
            # @bikes_policy_url="http://trimet.org/howtoride/bikes/bikepolicies.htm",
            # @fare_url="http://trimet.org/fares/",
            # @lang="en",
            # @name="TriMet",
            # @phone="503-238-7433",
            # @timezone="America/Los_Angeles",
            # @url="http://trimet.org"
            #>
          end

          calendar_dates = source.calendar_dates
          calendar_dates.each do |calendar_date|
            puts calendar_date
            #<GTFS::CalendarDate:0x007f9573061ed0 @date="20150125", @exception_type="1", @service_id="C.410">
          end

          fare_attributes = source.fare_attributes
          fare_attributes.each do |fare_attribute|
            puts fare_attribute
            #<GTFS::FareAttribute:0x007f9572d7a488
            # @currency_type="USD",
            # @fare_id="B",
            # @payment_method="0",
            # @price="2.5",
            # @transfer_duration="7200",
            # @transfers=nil
            #>
          end

          fare_rules = source.fare_rules
          fare_rules.each do |fare_rule|
            puts fare_rule
            #<GTFS::FareRule:0x007f9572d0b560 @contains_id="B", @fare_id="B", @origin_id="B", @route_id=nil>
          end

          routes = source.routes
          routes.each do |route|
            puts route
            #<GTFS::Route:0x007f9572ca0350
            #  @id="1",
            #  @long_name="Vermont",
            #  @short_name="1",
            #  @sort_order="400",
            #  @type="3",
            #  @url="http://trimet.org/schedules/r001.htm"
            #>
          end

          shapes = source.shapes # this takes a while
          shapes.each do |shape|
            puts shape
            #<GTFS::Shape:0x007fc284186980
            #  @dist_traveled="41.5",
            #  @id="233238",
            #  @pt_lat="45.522988",
            #  @pt_lon="-122.677431",
            #  @pt_sequence="3"
            #>
          end

          stop_times = source.stop_times # this takes a while
          stop_times.each do |stop_time|
            puts stop_time
            #
          end

          stops = source.stops
          stops.each do |stop|
            puts stop
            #<GTFS::Stop:0x007fc28f802560
            # @code="2",
            # @desc="Eastbound stop in Lake Oswego (Stop ID 2)",
            # @direction="East",
            # @id="2",
            # @lat="45.420597",
            # @location_type="0",
            # @lon="-122.675677",
            # @name="A Ave & Chandler",
            # @parent_station=nil,
            # @position="Nearside",
            # @url="http://trimet.org/arrivals/tracker?locationID=2",
            # @zone_id="B"
            #>
          end

          trips = source.trips
          trips.each do |trip|
            puts trip
            #<GTFS::Trip:0x007fc284a4d9b0
            # @block_id="3515",
            # @direction_id="1",
            # @id="5181824",
            # @route_id="35",
            # @service_id="W.410",
            # @shape_id="233470",
            # @type=nil
            #>
          end

        end

      rescue => e
        puts "#{e.class} -- #{e.message}"
      end
    end

    system "say 'process managed'" if Rails.env == "development"
  end
end
