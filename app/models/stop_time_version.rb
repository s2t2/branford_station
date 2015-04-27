class StopTimeVersion < ActiveRecord::Base
  belongs_to :version, :class_name => FeedVersion, :inverse_of => :stop_times
  #belongs_to :stop, :class_name => StopVersion, :foreign_key => "identifier", :inverse_of => :stop_times
  #belongs_to :trip, :class_name => TripVersion, :foreign_key => "identifier", :inverse_of => :stop_times
  #delegate :destination_stop_identifier, :to => :trip, :prefix => false

  def self.upcoming_arrivals
    order(:arrival_time) # .map{|st| st.serializable_hash.merge({:sort_time => st.arrival_time })}
  end

  def self.upcoming_departures
    order(:departure_time) # .map{|st| st.serializable_hash.merge({:sort_time => st.departure_time })}
  end

  def stop
    StopVersion.where(:identifier => stop_identifier).first
  end

  def trip
    TripVersion.where(:identifier => trip_identifier).first
  end

  def destination_stop_identifier
    trip.destination_stop_identifier
  end

  def origin_stop_identifier
    trip.origin_stop_identifier
  end

  def remarks
    "N/A"
  end
end
