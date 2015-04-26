class Feed < ActiveRecord::Base
  belongs_to :host, :class_name => FeedHost, :inverse_of => :feeds
    delegate :name, :to => :host, :prefix => true #=> feed.host_name
    delegate :url, :to => :host, :prefix => true #=> feed.host_url

  has_many :versions, :class_name => FeedVersion, :inverse_of => :feed

  ###class SourceUrlValidationError < ArgumentError ; end
  ###class UnexpectedUrlScheme < SourceUrlValidationError ; end
  ###class UnexpectedUrlFileFormat < SourceUrlValidationError ; end

  ###def self.create_from_source(source_url)
  ###  uri = URI.parse(source_url)
  ###  raise UnexpectedUrlScheme.new("Invalid source_url. It should start with 'http://' like 'http://www.myhost.com/my_transit.zip'.") unless uri.class == URI::HTTP
  ###  feed_name = uri.path.split("/").last
  ###  raise UnexpectedUrlFileFormat.new("Invalid source_url. After the host, it should contain a file name ending with '.zip' like 'http://www.myhost.com/my_transit.zip'.") unless feed_name.is_a?(String) && feed_name.ends_with?(".zip")

  ###  host = FeedHost.where(:name => uri.host).first_or_create

  ###  feed = Feed.where(:source_url => source_url, :host_id => host.id).first_or_initialize
  ###  feed.update_attributes(:name => feed_name)
  ###end

  def latest_version
    versions.latest
  end

  def latest_version_id
    latest_version.try(:id)
  end

  def last_modified_at
    latest_version.try(:last_modified_at)
  end

  def is_current
    latest_version.try(:is_current)
  end

  def most_recently_checked_version
    versions.most_recently_checked
  end

  def last_checked_at
    most_recently_checked_version.try(:last_checked_at)
  end

  def agency_names
    versions.map {|fv|
      fv.agencies.map {|a|
        a.name
      }
    }.flatten.uniq.sort.join(", ")
  end

  def agencies
    latest_version.agencies
  end

  def consume
    FeedConsumer.perform(:source_urls => [source_url], :load => true, :idempotence => false, :talkative => false)
  end

  def consume_light
    FeedConsumer.perform(:source_urls => [source_url], :load => true, :idempotence => true, :talkative => false)
  end
end
