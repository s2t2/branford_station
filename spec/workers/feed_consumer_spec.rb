require 'rails_helper'

RSpec.describe FeedConsumer do
  describe '#perform' do
    let(:source_urls){[
      #"http://www.cttransit.com/uploads_GTFS/googleha_transit.zip",
      #"http://www.cttransit.com/uploads_GTFS/googletest_transit.zip",
      #"http://www.cttransit.com/uploads_GTFS/googlenh_transit.zip",
      #"http://www.cttransit.com/uploads_GTFS/googlestam_transit.zip",
      #"http://www.cttransit.com/uploads_GTFS/googlewat_transit.zip",
      #"http://www.cttransit.com/uploads_GTFS/googlenb_transit.zip",
      #"http://www.cttransit.com/uploads_GTFS/googleme_transit.zip",
      #"http://dati.muovi.roma.it/gtfs/google_transit.zip",
      #"http://developer.trimet.org/schedule/gtfs.zip",
      "http://web.mta.info/developers/data/mnr/google_transit.zip",
      "http://www.shorelineeast.com/google_transit.zip",
    ]}
    let(:gtfs_data_directory){ "gtfs_filesystem" }

    context "filesystem" do
      let(:load){ false }

      it 'downloads feed files from source' do
        FeedConsumer.perform({:source_urls => source_urls, :load => load})

        source_urls.each do |source_url|
          uri = URI.parse(source_url)
          feed_host_name = uri.host
          feed_name = uri.path.split("/").last
          feed_versions_path = "#{gtfs_data_directory}/hosts/#{feed_host_name}/feeds/#{feed_name}/versions"
          expect(Dir.exists?(feed_versions_path)).to be_truthy
          expect(Dir.entries(feed_versions_path).size).to be > 0
        end
      end
    end

    context "database" do
      let(:load){ true }
      let(:agency_txt_sample_row){
        {
          "agency_id" => "SLE",
          " agency_name" => "Shore Line East",
          "agency_url" => "http://www.shorelineeast.com/",
          "agency_timezone" => "America/New_York",
          "agency_phone" => "1-877-287-4337",
          "agency_lang" => "en"
        } #<CSV::Row "agency_id":"SLE" " agency_name":"Shore Line East" "agency_url":"http://www.shorelineeast.com/" "agency_timezone":"America/New_York" "agency_phone":"1-877-287-4337" "agency_lang":"en">
      }

      it 'loads feed file contents into database' do
        AgencyVersion.destroy_all
        FeedConsumer.perform({:source_urls => source_urls, :load => load})
        expect(AgencyVersion.any?)
      end

      it 'handles minor discrepencies between actual agency.txt header names and expected agency.txt header names' do
        discrepency = {:expected_header_name => "agency_name", :actual_header_name => " agency_name"}
        value_from_expected_methodology = agency_txt_sample_row.send(:[], discrepency[:expected_header_name])
        value_from_actual_methodlogy = agency_txt_sample_row.send(:[], discrepency[:actual_header_name])

        expect([value_from_expected_methodology, value_from_actual_methodlogy].compact.any?)
      end
    end
  end
end
