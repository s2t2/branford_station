class Feed < ActiveRecord::Base
  has_many :versions, :inverse_of => :feed
end
