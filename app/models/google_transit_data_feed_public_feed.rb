require 'open-uri'
require 'nokogiri'

class GoogleTransitDataFeedPublicFeed < ActiveRecord::Base
  # A community-maintained wiki page including a table of public feed information.
  PUBLIC_FEEDS_WIKI_PAGE_URL = "https://code.google.com/p/googletransitdatafeed/wiki/PublicFeeds"

  # Persists all feeds listed on the public feeds wiki page.
  def self.extract_and_load!
    document = Nokogiri::HTML(open(PUBLIC_FEEDS_WIKI_PAGE_URL))
    tables = document.css("table")
    wiki_table = tables.find{|t| t.attributes["class"].try(:value) == "wikitable"}
    raise MissingWikiTableError.new("Instead found the following table classes: #{tables.map{|t| t.attributes["class"].try(:value)}}") unless wiki_table

    wiki_table_rows = wiki_table.css("tr")
    wiki_table_rows.each do |tr|

      # Skips the header row.
      next if tr.content.include?("Agency") && tr.content.include?("Area") && tr.content.include?("Feed Location") && tr.content.include?("Notes")

      # Ensure expected number of columns.
      tds = tr.css("td")
      raise UnexpectedNumberOfTableColumns unless tds.count == 4

      # Parse "Agency" column.
      agency_cell = tds[0]
      agency_link = agency_cell.css("a").first
      next unless agency_link
      agency_link_text = agency_link.children.text.strip
      agency_link_href = agency_link.attributes["href"].value

      # Parse "Area" column.
      area_cell = tds[1]
      agency_area = area_cell.children.text.strip

      # Parse "Feed Location" column.
      feed_cell = tds[2]
      feed_link = feed_cell.css("a").first
      feed_link_text = feed_link ? feed_link.children.text.strip : feed_cell.children.text.strip
      feed_href = feed_link ? feed_link.attributes["href"].value : feed_cell.children.text.strip
      next unless feed_href.ends_with?(".zip")

      # Parse "Notes" column.
      feed_notes_cell = tds[3]
      feed_notes = feed_notes_cell.content

      pp tr.content

      # Persist agency and feed information.

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
        :agency_id => public_feed_agency.id
        :name => feed_link_text,
        :notes => feed_notes
      })
    end
  end

  # Raised if the wiki table is missing.
  class MissingWikiTableError < StandardError ; end

  # Raised if the number of columns in any of the rows in the wiki table is unexpected.
  class UnexpectedNumberOfTableColumns < StandardError ; end
end
