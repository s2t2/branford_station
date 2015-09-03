class AgencyVersion < ActiveRecord::Base
  belongs_to :version, :class_name => FeedVersion, :inverse_of => :agencies
    delegate :name, :to => :version, :prefix => true #=> agency_version.version_name
    delegate :feed_id, :to => :version, :prefix => false #=> agency_version.feed_id
    delegate :feed_name, :to => :version, :prefix => false #=> agency_version.feed_name
    delegate :host_id, :to => :version, :prefix => false #=> agency_version.host_id
    delegate :host_name, :to => :version, :prefix => false #=> agency_version.host_name
    delegate :host_url, :to => :version, :prefix => false #=> agency_version.host_url
    delegate :source_url, :to => :version, :prefix => false #=> agency_version.source_url
    ###delegate :stops, :to => :version, :prefix => false #=> agency_verion.stops
end
