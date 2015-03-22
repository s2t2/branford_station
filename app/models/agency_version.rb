class AgencyVersion < ActiveRecord::Base
  belongs_to :version, :class_name => FeedVersion, :inverse_of => :agencies
end
