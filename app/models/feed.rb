class Feed < ActiveRecord::Base
  has_many :versions, :class_name => FeedVersion, :inverse_of => :feed
end
