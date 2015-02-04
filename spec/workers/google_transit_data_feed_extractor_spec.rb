require 'rails_helper'

RSpec.describe GoogleTransitDataFeedExtractor do
  let(:wiki_table_row){
    <<-HTML
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          <a href="http://www.trimet.org/" rel="nofollow">TriMet</a>
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;"> Portland, OR </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          <a href="http://developer.trimet.org/schedule/gtfs.zip" rel="nofollow">http://developer.trimet.org/schedule/gtfs.zip</a>
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;"> Use is subject to the terms of their <a href="http://developer.trimet.org/terms_of_use.shtml" rel="nofollow">developer license</a> </td>
      </tr>
    HTML
  }

  describe "perform" do
    it "ensures expected wikitable structure" do
      tr = Nokogiri::HTML(wiki_table_row)
      tds = tr.css("td")
      expect(tds.count).to eql(4)
    end

    it "persists agencies and feeds" do
      tr = Nokogiri::HTML(wiki_table_row)
      tds = tr.css("td")

      agency_cell = tds[0]
      agency_link = agency_cell.css("a").first
      agency_link_text = agency_link.children.text.strip
      agency_link_href = agency_link.attributes["href"].value

      area_cell = tds[1]
      agency_area = area_cell.children.text.strip

      feed_cell = tds[2]
      feed_link = feed_cell.css("a").first
      feed_link_text = feed_link ? feed_link.children.text.strip : feed_cell.children.text.strip
      feed_href = feed_link ? feed_link.attributes["href"].value : feed_cell.children.text.strip

      feed_notes_cell = tds[3]
      feed_notes = feed_notes_cell.content

      public_feed_agency = GoogleTransitDataFeedPublicFeedAgency.where({
        :url => agency_link_href
      }).first_or_create!
      public_feed_agency.update_attributes!({
        :name => agency_link_text,
        :area => agency_area
      })

      public_feed = GoogleTransitDataFeedPublicFeed.where({
        :url => feed_href
      }).first_or_create!
      public_feed.update_attributes({
        :agency_id => public_feed_agency.id,
        :name => feed_link_text,
        :notes => feed_notes
      })

      expect(public_feed.agency).to eql(public_feed_agency)
    end
  end
end
