class FeedVersion < ActiveRecord::Base
  belongs_to :feed, :inverse_of => :versions
end
