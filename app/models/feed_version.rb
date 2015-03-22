class FeedVersion < ActiveRecord::Base
  belongs_to :feed, :inverse_of => :versions
  has_many :agencies, :class_name => AgencyVersion, :foreign_key => :version_id, :inverse_of => :version

  def self.latest
    order(:last_modified_at).last
  end
end
