require 'zip'

class FeedFileExtractor
  GTFS_DATA_DIRECTORY = "db/gtfs"

  FEED_FILE_NAMES = ["agency.txt", "stops.txt", "routes.txt", "trips.txt", "stop_times.txt",
    "calendars.txt", "calendar_dates.txt", "shapes.txt", "fare_attributes.txt",
    "fare_rules.txt", "frequencies.txt", "transfers.txt"
  ]

  # Extract feed files from source.
  #
  # @examples
  #    FeedFileExtractor.perform(:source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"])
  #    FeedFileExtractor.perform
  #
  # @param [Hash] options
  # @option options [Array] :source_urls ([])
  #
  def self.perform(options = {})
    source_urls = options[:source_urls] || []
    source_urls += DataExchangeAgency.pluck(:feed_baseurl)
    source_urls += GoogleTransitDataFeedPublicFeed.pluck(:url)
    source_urls = source_urls.compact.uniq.select{|url| url.ends_with?(".zip")}

    puts "EXTRACTING FEED FILES FROM #{source_urls.length} SOURCES"

    source_urls.each do |source_url|
      next unless source_url.ends_with?(".zip")
      begin

        # Check/validate feed version.

        uri = URI.parse(source_url)
        next unless uri.scheme == "http"
        next unless uri.host

        response = Net::HTTP.get_response(uri)
        raise MissingEtag.new(source_url) unless response.to_hash["etag"]
        raise MissingLastModified.new(source_url) unless response.to_hash["last-modified"]

        etag = response.to_hash["etag"].first.gsub!(/[^0-9A-Za-z]/, '')
        last_modified_at = response.to_hash["last-modified"].first.try(:to_datetime)
        raise EtagError.new(etag) unless etag.is_a?(String)
        raise LastModifiedError.new(last_modified_at) unless last_modified_at.is_a?(DateTime)

        # Create a local directory for storing feed files.

        destination_path = "#{GTFS_DATA_DIRECTORY}/hosts/#{uri.host}/feeds/#{uri.path.gsub("/","--").slice(1..-1)}/versions/#{last_modified_at.to_s}"

        puts "FEED FILE DESTINATION -- #{destination_path}"

        FileUtils.mkdir_p(destination_path)

        # Download zipped feed files.

        zip_destination_path = "#{destination_path}/#{source_url.split("/").last}"
        unless File.exist?(zip_destination_path)
          File.open(zip_destination_path, "wb") do |zip_file|
            zip_file.write response.body
          end
          raise SourceExtractionError.new(zip_destination_path) unless File.exist?(zip_destination_path)
        end

        # Unzip feed files.

        Zip::File.open(zip_destination_path) do |zip_file|
          zip_file.each do |entry|
            begin
              entry_name = entry.name
              raise InvalidEntryName.new(entry_name) unless FEED_FILE_NAMES.include?(entry_name)

              feed_file_path = "#{destination_path}/#{entry_name}"
              raise FeedFileExists.new(feed_file_path) if File.exist?(feed_file_path)

              entry.extract(feed_file_path)
              raise FeedFileExtractionError.new(feed_file_path) unless File.exist?(feed_file_path)
            rescue InvalidEntryName => e
              next
            rescue FeedFileExists => e
              next
            end
          end
        end

        # Remove zip file, if necessary.

        FileUtils.rm(zip_destination_path)
        raise SourceRemovalError.new(zip_destination_path) if File.exist?(zip_destination_path)

      rescue => e
        puts "#{e.class} -- #{e.message}"
      end
    end

    system "say 'process managed'"
  end

  class MissingEtag < StandardError
  end

  class MissingLastModified < StandardError
  end

  class EtagError < StandardError
  end

  class LastModifiedError < StandardError
  end

  class SourceExtractionError < StandardError
  end

  class InvalidEntryName < StandardError
  end

  class FeedFileExists < StandardError
  end

  class FeedFileExtractionError < StandardError
  end

  class SourceRemovalError < StandardError
  end
end
