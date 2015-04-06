class FeedVersion < ActiveRecord::Base
  belongs_to :feed, :inverse_of => :versions

    delegate :name, :to => :feed, :prefix => true #=> feed_version.feed_name
    delegate :source_url, :to => :feed, :prefix => false
    delegate :host_id, :to => :feed, :prefix => false
    delegate :host_name, :to => :feed, :prefix => false
    delegate :host_url, :to => :feed, :prefix => false

  has_many :agencies, :class_name => AgencyVersion, :foreign_key => :version_id, :inverse_of => :version

  #RECENCY_THRESHOLDS = [
  #  {:name => "current", :distance_from_now => 4.hours},
  #  {:name => "aging", :distance_from_now => 8.hours},
  #  {:name => "stale", :distance_from_now => 16.hours}
  #]

  RECENCY_THRESHOLD = 4.hours

  def self.latest
    order(:last_modified_at).last
  end

  def self.most_recently_checked
    order(:last_checked_at).last
  end

  def name
    etag.gsub("[","").gsub("]","").gsub("/","").gsub("\\","").gsub('"',"") #todo: consume as string instead of array, use regular experession to escape slashes and quotes (and all special characters?)
  end

  def is_latest
    self == feed.latest_version
  end

  def is_current
    RECENCY_THRESHOLD > Time.zone.now - last_checked_at ? true : false
  end
end
