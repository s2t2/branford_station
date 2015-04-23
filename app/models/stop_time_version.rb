class StopTimeVersion < ActiveRecord::Base
  belongs_to :stop, :class_name => StopVersion, :inverse_of => :stop
end
