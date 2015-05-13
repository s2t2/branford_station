class StopTimeVersion < ActiveRecord::Base
  belongs_to :version, :class_name => FeedVersion, :inverse_of => :stop_times
  #belongs_to :stop, :class_name => StopVersion, :foreign_key => "identifier", :inverse_of => :stop_times
  #belongs_to :trip, :class_name => TripVersion, :foreign_key => "identifier", :inverse_of => :stop_times
  #delegate :destination_stop_identifier, :to => :trip, :prefix => false

  def self.upcoming_arrivals
    where("time_to_sec(stop_time_versions.arrival_time) >= time_to_sec(now())").order("time_to_sec(stop_time_versions.arrival_time)")
  end

  def self.upcoming_departures
    # get the timezone of the stop. if it is null, get the timezone of the agency.
    # convert 'America/New_York' to 'Eastern Time (US & Canada)'
    #stop_time_zone = 'Eastern Time (US & Canada)'
    #  DateTime.parse(st.arrival_time).in_time_zone(stop_time_zone)
    where("time_to_sec(stop_time_versions.departure_time) >= time_to_sec(now())")
    .order("time_to_sec(stop_time_versions.departure_time)")
  end

  def stop
    StopVersion.where(:identifier => stop_identifier).first
  end

  def trip
    TripVersion.where(:identifier => trip_identifier).first
  end

  def route_identifier
    trip.route_identifier
  end

  def service_identifier
    trip.service_identifier
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
