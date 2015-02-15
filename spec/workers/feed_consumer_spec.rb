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
      #"http://www.shorelineeast.com/google_transit.zip",
      #"http://dati.muovi.roma.it/gtfs/google_transit.zip",
      "http://developer.trimet.org/schedule/gtfs.zip"
    ]}

    context "when choosing a filesystem load strategy" do
      let(:load_strategy){ "filesystem" }
      let(:gtfs_data_directory){ "gtfs" }

      it 'downloads source files' do
        FeedConsumer.perform({:source_urls => source_urls, :load_strategy => load_strategy})

        source_urls.each do |source_url|
          uri = URI.parse(source_url)
          feed_host_name = uri.host
          feed_name = uri.path.split("/").last
          feed_versions_path = "#{gtfs_data_directory}/hosts/#{feed_host_name}/feeds/#{feed_name}/versions"
          expect(Dir.exists?(feed_versions_path)).to be_truthy
          expect(Dir.entries(feed_versions_path).size).to be_greater_than 0
        end
      end
    end

    context "when choosing a database load strategy" do
      let(:load_strategy){ "database" }

      it 'loads source files into database' do
        FeedConsumer.perform({:source_urls => source_urls, :load_strategy => load_strategy})
        true
      end
    end
  end
end
