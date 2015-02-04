class FeedExtractor
  def self.perform
    #feed_source_urls = [
    #  "http://www.shorelineeast.com/google_transit.zip",
    #  "http://web.mta.info/developers/data/mnr/google_transit.zip"
    #]

    feed_source_urls = DataExchangeAgency.pluck(:feed_baseurl)
    feed_source_urls += GoogleTransitDataFeedPublicFeed.pluck(:url)
    feed_source_urls = feed_source_urls.compact.uniq.select{|url| url.ends_with?(".zip")}

    FeedManager.perform(feed_source_urls)
  end
end
