class TripVersion < ActiveRecord::Base
  #has_many :stop_times, :class_name => StopTimeVersion, :foreign_key => :trip_identifier, :inverse_of => :trip

  def stop_times
    StopTimeVersion.where(:trip_identifier => identifier)
  end

  def destination_stop_identifier
    stop_times.order(:stop_sequence).last.stop_identifier
  end

  def origin_stop_identifier
    stop_times.order(:stop_sequence).first.stop_identifier
  end
end
