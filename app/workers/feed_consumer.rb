require 'zip'

class FeedConsumer
  FEED_FILE_NAMES = ["agency.txt", "stops.txt", "routes.txt", "trips.txt", "stop_times.txt",
    "calendars.txt", "calendar_dates.txt", "shapes.txt", "fare_attributes.txt",
    "fare_rules.txt", "frequencies.txt", "transfers.txt"
  ]

  def self.gtfs_data_directory
    "db/gtfs"
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
  # @option options [boolean] :load (true)
  # @option options [boolean] :remove_txts (false)
  # @option options [boolean] :remove_zips (false)
  #
  def self.perform(options = {})
    source_urls = options[:source_urls] || []
    load_request = options[:load] || true
    transit_data_feed_request = options[:transit_data_feed] || false
    data_exchange_request = options[:data_exchange] || false
    txt_file_removal_request = options[:remove_txts] || false
    zip_file_removal_request = options[:remove_zips] || false

    source_urls += [
        "http://www.cttransit.com/uploads_GTFS/googleha_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googletest_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googlenh_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googlestam_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googlewat_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googlenb_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googleme_transit.zip",
        "http://www.shorelineeast.com/google_transit.zip"
    ] #for testing
    source_urls += DataExchangeAgency.pluck(:feed_baseurl) if data_exchange_request == true
    source_urls += GoogleTransitDataFeedPublicFeed.pluck(:url) if transit_data_feed_request == true
    source_urls = source_urls.compact.uniq.select{|url| url.ends_with?(".zip")}
    puts "FOUND #{source_urls.length} SOURCES FOR CONSUMPTION"
    source_urls.each do |source_url|
      begin

        # Parse source url to identify host and feed.

        uri = URI.parse(source_url)
        puts uri
        feed_host_name = uri.host              
        feed_name = uri.path.split("/").last #feed_name = uri.path.slice(1..-1).gsub("/","-").gsub("_","-").downcase # given source_url of "http://developer.trimet.org/schedule/gtfs.zip", and path of "/schedule/gtfs.zip", remove the leading slash, "schedule/gtfs.zip" and comvert remaining slashes to dashes for file directory naming purposes "schedule-gtfs.zip"
        next unless feed_host_name && feed_name

        if load_request == true
          feed_host = FeedHost.where(:name => feed_host_name).first_or_create
          feed = Feed.where(
            :source_url => source_url,
            :host_id => feed_host.id
          ).first_or_create!
          feed.update_attributes!(:name => feed_name)
        end

        # Make a feed request to at least identify its current version, if not also to download updated files.

        next unless uri.scheme == "http"
        response = Net::HTTP.get_response(uri)
        response_header = response.to_hash
        pp "=> #{response_header}"
        next unless response_header
        last_modified_at = response_header["last-modified"].try(:first).try(:to_datetime)
        next unless last_modified_at && last_modified_at.is_a?(DateTime)

        if load_request == true
          feed_release_version = FeedVersion.where(
            :feed_id => feed.id,
            :last_modified_at => last_modified_at
          ).first_or_create!
          feed_release_version.update_attributes!(
            :last_checked_at => Time.zone.now,
            :response_code => response.code.to_i, #.try(:to_i),
            :response_message => response.message.to_s,
            :accept_ranges => response_header["accept-ranges"],
            #:access_control_allow_origin => response_header["access-control-allow-origin"],
            :cache_control => response_header["cache-control"],
            :connection => response_header["connection"],
            :content_type => response_header["content-type"],
            #:content_disposition => response_header["content-disposition"],
            :content_language => response_header["content-language"],
            :content_length => response_header["content-length"],
            :etag => response_header["etag"], #response_header["etag"].try(:first).gsub!(/[^0-9A-Za-z]/, ''),
            :expires => response_header["expires"].try(:first).try(:to_datetime),
            #:location => response_header["location"],
            :server => response_header["server"],
            #:vary => response_header["vary"],
            #:transfer_encoding => response_header["transfer-encoding"],
            #:x_aspnet_version => response_header["x-aspnet-version"],
            #:x_frame_options => response_header["x-frame-options"],
            :x_powered_by => response_header["x-powered-by"],
            #:x_ua_compatible => response_header["x-ua-compatible"],
            :set_cookie => response_header["set-cookie"]
          )
        end

        # Download feed files, but stop if the files already exist (have been downloaded but not cleaned-up).

        destination_path = "#{gtfs_data_directory}/hosts/#{feed_host_name}/feeds/#{feed_name}/versions/#{last_modified_at}"
        FileUtils.mkdir_p(destination_path)

        zip_file_name = feed_name
        zip_file_path = "#{destination_path}/#{zip_file_name}"
        File.open(zip_file_path, "wb") do |zip_file|
          zip_file.write response.body # this raises ...
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

        FileUtils.rm(zip_file_path) if zip_file_removal_request == true

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



        #stops_file_path = "#{destination_path}/stops.txt"
        #if File.exist?(stops_file_path)
        #  stops = CSV.read("public_restrooms_sf.csv", :headers => true)
        #else
        #  raise "COULDNT FIND STOPS FILE"
        #end







        # Remove the feed txt files.

        # agencies
        # calendar_dates
        # fare_attributes
        # fare_rules
        # routes
        # shapes
        # stop_times
        # stops
        # trips

        if txt_file_removal_request == true
          FEED_FILE_NAMES.each do |feed_file_name|
            puts "removing #{destination_path}/#{feed_file_name}.txt"
          end
        end
      rescue => e
        puts "#{e.class} -- #{e.message}"
      end
    end

    #system "say 'process managed'"
  end
end
