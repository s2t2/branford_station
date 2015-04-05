class Feed < ActiveRecord::Base
  belongs_to :host, :class_name => FeedHost, :inverse_of => :feeds
    delegate :name, :to => :host, :prefix => true #=> feed.host_name
    delegate :url, :to => :host, :prefix => true #=> feed.host_url

  has_many :versions, :class_name => FeedVersion, :inverse_of => :feed

  def latest_version
    versions.latest
  end

  def last_modified_at
    latest_version.try(:last_modified_at)
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
end
