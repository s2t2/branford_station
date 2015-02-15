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
  # @option options [boolean] :load (true)
  # @option options [boolean] :clean_up (false)
  #
  def self.perform(options = {})
    source_urls = options[:source_urls] || []
    load_step = options[:load] || true
    clean_up_step = options[:clean_up] || false

    source_urls += [
        "http://www.cttransit.com/uploads_GTFS/googleha_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googletest_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googlenh_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googlestam_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googlewat_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googlenb_transit.zip",
        "http://www.cttransit.com/uploads_GTFS/googleme_transit.zip",
        "http://www.shorelineeast.com/google_transit.zip"
    ]
    source_urls += DataExchangeAgency.pluck(:feed_baseurl)
    source_urls += GoogleTransitDataFeedPublicFeed.pluck(:url)
    source_urls = source_urls.compact.uniq.select{|url| url.ends_with?(".zip")}

    puts "FOUND #{source_urls.length} SOURCES FOR CONSUMPTION"

    source_urls.each do |source_url|
      begin

        # Detect feed and feed host.

        uri = URI.parse(source_url)
        puts uri
        feed_host_name = uri.host              
        feed_name = uri.path.split("/").last #feed_name = uri.path.slice(1..-1).gsub("/","-").gsub("_","-").downcase # given source_url of "http://developer.trimet.org/schedule/gtfs.zip", and path of "/schedule/gtfs.zip", remove the leading slash, "schedule/gtfs.zip" and comvert remaining slashes to dashes for file directory naming purposes "schedule-gtfs.zip"
        next unless feed_host_name && feed_name

        if load_step == true
          feed_host = FeedHost.where(:name => feed_host_name).first_or_create
          feed = Feed.where(
            :source_url => source_url,
            :host_id => feed_host.id
          ).first_or_create!
          feed.update_attributes!(:name => feed_name)
        end

        # Detect feed version.

        next unless uri.scheme == "http"
        response = Net::HTTP.get_response(uri)
        response_header = response.to_hash
        pp "=> #{response_header}"
        next unless response_header
        last_modified_at = response_header["last-modified"].try(:first).try(:to_datetime)
        next unless last_modified_at && last_modified_at.is_a?(DateTime)

        if load_step == true
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
            :content_disposition => response_header["content-disposition"],
            :content_language => response_header["content-language"],
            :content_length => response_header["content-length"],
            :etag => response_header["etag"], #response_header["etag"].try(:first).gsub!(/[^0-9A-Za-z]/, ''),
            :expires => response_header["expires"].try(:first).try(:to_datetime),
            :location => response_header["location"],
            :server => response_header["server"],
            :vary => response_header["vary"],
            :transfer_encoding => response_header["transfer-encoding"],
            #:x_aspnet_version => response_header["x-aspnet-version"],
            #:x_frame_options => response_header["x-frame-options"],
            :x_powered_by => response_header["x-powered-by"],
            #:x_ua_compatible => response_header["x-ua-compatible"],
            :set_cookie => response_header["set-cookie"]
          )
        end

        # Extract feed files.

        #destination_path = "#{gtfs_data_directory}/hosts/#{feed_host_name}/feeds/#{feed_name}/versions/#{last_modified_at}"
        #FileUtils.mkdir_p(destination_path)

        #zip_destination_path = "#{destination_path}/#{source_url.split("/").last}"
        #unless File.exist?(zip_destination_path)
        #  File.open(zip_destination_path, "wb") do |zip_file|
        #    zip_file.write response.body
        #  end
        #  raise SourceExtractionError.new(zip_destination_path) unless File.exist?(zip_destination_path)
        #end

        #Zip::File.open(zip_destination_path) do |zip_file|
        #  zip_file.each do |entry|
        #    begin
        #      entry_name = entry.name
        #      raise InvalidEntryName.new(entry_name) unless FEED_FILE_NAMES.include?(entry_name)

        #      feed_file_path = "#{destination_path}/#{entry_name}"
        #      raise FeedFileExists.new(feed_file_path) if File.exist?(feed_file_path)

        #      entry.extract(feed_file_path)
        #      raise FeedFileExtractionError.new(feed_file_path) unless File.exist?(feed_file_path)
        #    rescue InvalidEntryName => e
        #      next
        #    rescue FeedFileExists => e
        #      next
        #    end
        #  end
        #end

        # Remove zip file, if necessary.

        #FileUtils.rm(zip_destination_path)
        #raise SourceRemovalError.new(zip_destination_path) if File.exist?(zip_destination_path)

        # Load feed files.

      rescue => e
        puts "#{e.class} -- #{e.message}"
      end
    end

    system "say 'process managed'"
  end

  #class LastModifiedError < StandardError
  #end
#
  #class SourceExtractionError < StandardError
  #end
#
  #class InvalidEntryName < StandardError
  #end
#
  #class FeedFileExists < StandardError
  #end
#
  #class FeedFileExtractionError < StandardError
  #end
#
  #class SourceRemovalError < StandardError
  #end
end
