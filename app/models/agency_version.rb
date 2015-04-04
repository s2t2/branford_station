class AgencyVersion < ActiveRecord::Base
  belongs_to :version, :class_name => FeedVersion, :inverse_of => :agencies

  def feed_name
    version.feed_name
  end

  def host_id
    version.feed_host_id
  end

  def host_name
    version.feed_host_name
  end

  def host_url
    version.feed_host_url
  end

  def download_url
    version.feed_source_url
  end
end
