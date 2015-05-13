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
      let(:agency_txt_sample_row){ #<CSV::Row "agency_id":"SLE" " agency_name":"Shore Line East" "agency_url":"http://www.shorelineeast.com/" "agency_timezone":"America/New_York" "agency_phone":"1-877-287-4337" "agency_lang":"en">
        {
          "agency_id" => "SLE",
          " agency_name" => "Shore Line East",
          "agency_url" => "http://www.shorelineeast.com/",
          "agency_timezone" => "America/New_York",
          "agency_phone" => "1-877-287-4337",
          "agency_lang" => "en"
        }
      }
      let(:stops_txt_sample_row){ #<CSV::Row "stop_id":"1" "stop_code":nil "stop_name":"Grand Central" "stop_desc":nil "stop_lat":"40.752998" "stop_lon":"-73.977056" "zone_id":nil "stop_url":"http://as0.mta.info/mnr/stations/station_detail.cfm?key=1" "location_type":"0" "parent_station":nil "wheelchair_accessible":"1">
        {
          "stop_id"=>"1",
          "stop_code"=>nil,
          "stop_name"=>"Grand Central",
          "stop_desc"=>nil,
          "stop_lat"=>"40.752998",
          "stop_lon"=>"-73.977056",
          "zone_id"=>nil,
          "stop_url"=>"http://as0.mta.info/mnr/stations/station_detail.cfm?key=1",
          "location_type"=>"0",
          "parent_station"=>nil,
          "wheelchair_accessible"=>"1"
        }
      }
      let(:stops_txt_sample_row_with_precise_lat_long){ #<CSV::Row "stop_id":"BRN" "stop_name":"Branford" "stop_lat":"41.27462757904543" "stop_lon":" -72.81724601984024" "zone_id":"2" "stop_url":"http://www.shorelineeast.com/service_info/stations/branford.php">
        {
          "stop_id"=>"BRN",
          "stop_name"=>"Branford",
          "stop_lat"=>"41.27462757904543",
          "stop_lon"=>" -72.81724601984024",
          "zone_id"=>"2",
          "stop_url"=>"http://www.shorelineeast.com/service_info/stations/branford.php"
        }
      }
      let(:stop_version_with_rounded_latlong){ #<StopVersion:0x007fac8c2d2ef0 id: 160, version_id: 3, identifier: "BRN", code: nil, name: "Branford", description: nil, latitude: #<BigDecimal:7fac8c2f1e90,'0.41274628E2',18(27)>, longitude: #<BigDecimal:7fac8c301548,'-0.72817246E2',18(27)>, zone_identifier: "2", url: "http://www.shorelineeast.com/service_info/stations/branford.php", location_type: nil, parent_station: nil, timezone: nil, wheelchair_boarding: nil, created_at: Sat, 02 May 2015 22:23:37 UTC +00:00, updated_at: Wed, 13 May 2015 01:13:11 UTC +00:00>
        {
          "id"=>160,
          "version_id"=>3,
          "identifier"=>"BRN",
          "code"=>nil,
          "name"=>"Branford",
          "description"=>nil,
          "latitude"=>"41.27462800",
          "longitude"=>"-72.81724600",
          "zone_identifier"=>"2",
          "url"=>"http://www.shorelineeast.com/service_info/stations/branford.php",
          "location_type"=>nil,
          "parent_station"=>nil,
          "timezone"=>nil,
          "wheelchair_boarding"=>nil,
          "created_at"=>"Sat, 02 May 2015 22:23:37 UTC +00:00",
          "updated_at"=>"Wed, 13 May 2015 01:13:11 UTC +00:00"
        }
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

      it 'properly compares csv lat/long values to database lat/long values' do
        row = stops_txt_sample_row_with_precise_lat_long
        stop = stop_version_with_rounded_latlong

        expect( row["stop_lat"].strip.to_f.round(6) == stop["latitude"].to_f.round(6) )
        expect( row["stop_lon"].strip.to_f.round(6) == stop["longitude"].to_f.round(6) )
      end
    end
  end
end
