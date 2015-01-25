require 'rails_helper'

RSpec.describe DataExchangeAgency, :type => :model do
  describe '#extract_and_load!' do
    it 'persists all agencies known to the gtfs data exchange' do
      identified_agency = {
        :date_last_updated=>1354248333.0,
        :feed_baseurl=>nil,
        :name=>"A. Reich GmbH Busbetrieb",
        :area=>nil,
        :url=>"http://www.vbb.de",
        :country=>nil,
        :state=>nil,
        :license_url=>nil,
        :dataexchange_url=>"http://www.gtfs-data-exchange.com/agency/a-reich-gmbh-busbetrieb/",
        :date_added=>1354248333.0,
        :is_official=>false,
        :dataexchange_id=>"a-reich-gmbh-busbetrieb"
      }

      agency = DataExchangeAgency.where(
        :dataexchange_id => identified_agency[:dataexchange_id]
      ).first_or_create

      agency.update_attributes(
        :name => identified_agency[:name],
        :url => identified_agency[:url],
        :dataexchange_url => identified_agency[:dataexchange_url],
        :feed_baseurl => identified_agency[:feed_baseurl],
        :license_url => identified_agency[:license_url],
        :area => identified_agency[:area],
        :state => identified_agency[:state],
        :country => identified_agency[:country],
        :is_official => identified_agency[:is_official],
        :date_added => Time.at(identified_agency[:date_added].to_i).to_datetime,
        :date_last_updated => Time.at(identified_agency[:date_last_updated].to_i).to_datetime
      )

      expect(DataExchangeAgency.where(:name => identified_agency[:name]).exists?).to be_truthy
    end

    it 'does not persist un-identified agencies' do
      unidentified_agency = {
        :date_last_updated=>1310110392.0,
        :feed_baseurl=>nil,
        :name=>"ЛКП «Львівелектротранс»",
        :area=>nil,
        :url=>"http://www.city-adm.lviv.ua/adm/comunale-enterprise/lvivelektrotrans-",
        :country=>nil,
        :state=>nil,
        :license_url=>nil,
        :dataexchange_url=>"http://www.gtfs-data-exchange.com/agency//",
        :date_added=>1310110392.0,
        :is_official=>false,
        :dataexchange_id=>nil
      }

      expect(DataExchangeAgency.where(:name => unidentified_agency[:name]).exists?).to be_falsey
    end
  end
end
