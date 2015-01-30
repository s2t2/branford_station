require 'open-uri' # avoid `Errno::ENOENT: No such file or directory @ rb_sysopen - https://code.google.com/p/googletransitdatafeed/wiki/PublicFeeds`
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
    wiki_table_rows.each do |row|
      next if row.content.include?("Agency") && row.content.include?("Area") && row.content.include?("Feed") && row.content.include?("Location") && row.content.include?("Notes") # header_row
      pp row.content
    end
  end

  # Raised in the event of a nonexistant wiki table.
  class MissingWikiTableError < StandardError ; end
end
