class FeedConsumer
  FEED_FILE_NAMES = ["agency.txt","stops.txt","routes.txt","trips.txt","stop_times.txt","calendars.txt","calendar_dates.txt","shapes.txt","fare_attributes.txt","fare_rules.txt","frequencies.txt","transfers.txt"]

  def self.gtfs_data_directory
    "gtfs_filesystem"
  end

  # Extract feed files from source.
  #
  # @examples
  #    FeedConsumer.perform
  #    FeedConsumer.perform(:data_exchange => true)
  #    FeedConsumer.perform(:load => false, :source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"])
  #    FeedConsumer.perform(:load => true, :source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"])
  #
  # @param [Hash] options
  # @option options [Array] :source_urls ([])
  # @option options [boolean] :transit_data_feed (false) Whether or not to include sources from the google transit data feed.
  # @option options [boolean] :data_exchange (false) Whether or not to include sources from the data exchange.
  # @option options [boolean] :load (false) Whether or not to load file contents into the database.
  # @option options [boolean] :talkative (true) Whether or not to verbally alert the user when the process is complete.
  #
  def self.perform(options = {})
    load_request = options[:load] || false
    transit_data_feed_request = options[:transit_data_feed] || false
    data_exchange_request = options[:data_exchange] || false
    source_urls = options[:source_urls] || []
    idempotence_request = options[:idempotence] || false
    talkative = options[:talkative].nil? ? (Rails.env == "development" ? true : false) : options[:talkative]

    # Compile source urls.

    source_urls += DataExchangeAgency.pluck(:feed_baseurl) if data_exchange_request == true
    source_urls += GoogleTransitDataFeedPublicFeed.pluck(:url) if transit_data_feed_request == true
    source_urls = source_urls.compact.uniq.select{|url| url.ends_with?(".zip")}
    puts "DISCOVERED #{source_urls.length} SOURCES"

    source_urls.each do |source_url|
      begin

        # Parse source url.

        uri = URI.parse(source_url)
        feed_host_name = uri.host
        feed_name = uri.path.split("/").last
        puts uri

        next unless feed_host_name && feed_name
        feed_host = FeedHost.where(:name => feed_host_name).first_or_create # todo maybe store the feed_host_name as feed.url instead of feed_name as feed.name ...
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

        # Handle moved/redirected source. TODO: refactor this into a shared method...

        if last_modified_at.nil? && response_head.class == Net::HTTPMovedPermanently && response_header["location"].present?

          # Parse source url.

          uri = URI.parse(response_header["location"].first)
          feed_host_name = uri.host
          feed_name = uri.path.split("/").last
          puts uri

          next unless feed_host_name && feed_name
          feed_host = FeedHost.where(:name => feed_host_name).first_or_create # todo maybe store the feed_host_name as feed.url instead of feed_name as feed.name ...
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
        end

        next unless last_modified_at && last_modified_at.is_a?(DateTime)
        version = FeedVersion.where(
          :feed_id => feed.id,
          :last_modified_at => last_modified_at
        ).first_or_create!
        version.update_attributes!(
          :last_checked_at => Time.zone.now,
          :response_code => response_head.code.to_i,
          :response_message => response_head.message.to_s,
          :accept_ranges => response_header["accept-ranges"].try(:first),
          :cache_control => response_header["cache-control"].try(:first),
          :connection => response_header["connection"].try(:first),
          :content_type => response_header["content-type"].try(:first),
          :content_language => response_header["content-language"].try(:first),
          :content_length => response_header["content-length"].try(:first),
          :etag => response_header["etag"], #.try(:first),
          :expires => response_header["expires"].try(:first).try(:to_datetime),
          :server => response_header["server"].try(:first),
          :x_powered_by => response_header["x-powered-by"].try(:first),
          :set_cookie => response_header["set-cookie"].try(:first)
        )

        next if idempotence_request == true && version.is_current && version.agencies.any? && version.stops.any? && version.stop_times.any?

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

        next unless load_request == true

        # Load file contents into database.

        # Load Agencies.

        agency_txt = "#{destination_path}/agency.txt"
        next unless File.exist?(agency_txt)

        CSV.foreach(agency_txt, :headers => true) do |row|
          agency_version = AgencyVersion.where(
            :version_id => version.id,
            :name => row["agency_name"] || row[" agency_name"],
            :url => row["agency_url"],
            :timezone => row["agency_timezone"],
          ).first_or_create!
          agency_version.update_attributes!(
            :identifier => row["agency_id"],
            :lang => row["agency_lang"],
            :phone => row["agency_phone"],
            :fare_url => row["agency_fare_url"]
          )
        end

        # Load Stops.

        stops_txt = "#{destination_path}/stops.txt"
        next unless File.exist?(stops_txt)

        CSV.foreach(stops_txt, :headers => true) do |row|
          stop_version = StopVersion.where(
            :version_id => version.id,
            :identifier => row["stop_id"],
            :name => row["stop_name"],
            :latitude => row["stop_lat"],
            :longitude => row["stop_lon"],
          ).first_or_create!
          stop_version.update_attributes!(
            :code => row["stop_code"],
            :description => row["stop_desc"],
            :zone_identifier => row["zone_id"],
            :url => row["stop_url"],
            :location_type => row["location_type"],
            :parent_station => row["parent_station"],
            :timezone => row["stop_timezone"],
            :wheelchair_boarding => row["wheelchair_boarding"]
          )
        end

        # Load StopTimes.

        stop_times_txt = "#{destination_path}/stop_times.txt"
        next unless File.exist?(stop_times_txt)

        CSV.foreach(stop_times_txt, :headers => true) do |row|
          stop_time_version = StopTimeVersion.where(
            :version_id => version.id,
            :trip_identifier => row["trip_id"],
            :stop_identifier => row["stop_id"],
            :stop_sequence => row["stop_sequence"],
            :arrival_time => row["arrival_time"],
            :departure_time => row["departure_time"]
          ).first_or_create!
          stop_time_version.update_attributes!(
            :stop_headsign => row["stop_headsign"],
            :pickup_type => row["pickup_type"],
            :drop_off_type => row["drop_off_type"],
            :shape_dist_traveled => row["shape_dist_traveled"],
            :timepoint => row["timepoint"]
          )
        end

      rescue => e
        puts "#{e.class} -- #{e.message}"
        next
      end
    end

    system "say 'process managed'" if talkative == true
  end
end
