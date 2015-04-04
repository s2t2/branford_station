class FeedVersion < ActiveRecord::Base
  belongs_to :feed, :inverse_of => :versions
    delegate :name, :to => :feed, :prefix => true #=> feed_version.feed_name
    delegate :source_url, :to => :feed, :prefix => true #=> feed_version.feed_source_url
    delegate :host_id, :to => :feed, :prefix => true #=> feed_version.feed_host_id
    delegate :host_name, :to => :feed, :prefix => true #=> feed_version.feed_host_name
    delegate :host_url, :to => :feed, :prefix => true #=> feed_version.feed_host_url

  has_many :agencies, :class_name => AgencyVersion, :foreign_key => :version_id, :inverse_of => :version

  def self.latest
    order(:last_modified_at).last
  end

  def self.most_recently_checked
    order(:last_checked_at).last
  end
end
