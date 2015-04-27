class CreateTripVersions < ActiveRecord::Migration
  def change
    create_table :trip_versions do |t|
      t.integer :version_id, :null => false

      # https://developers.google.com/transit/gtfs/reference#trips_fields
      t.string :route_identifier, :null => false # route_id Required The route_id field contains an ID that uniquely identifies a route. This value is referenced from the routes.txt file.
      t.string :service_identifier, :null => false # service_id Required The service_id contains an ID that uniquely identifies a set of dates when service is available for one or more routes. This value is referenced from the calendar.txt or calendar_dates.txt file.
      t.string :identifier, :null => false # trip_id Required The trip_id field contains an ID that identifies a trip. The trip_id is dataset unique.
      t.string :headsign # trip_headsign Optional The trip_headsign field contains the text that appears on a sign that identifies the trip's destination to passengers. Use this field to distinguish between different patterns of service in the same route. If the headsign changes during a trip, you can override the trip_headsign by specifying values for the the stop_headsign field in stop_times.txt.
      t.string :short_name # trip_short_name Optional The trip_short_name field contains the text that appears in schedules and sign boards to identify the trip to passengers, for example, to identify train numbers for commuter rail trips. If riders do not commonly rely on trip names, please leave this field blank. A trip_short_name value, if provided, should uniquely identify a trip within a service day; it should not be used for destination names or limited/express designations.
      t.integer :direction_identifier # direction_id Optional The direction_id field contains a binary value that indicates the direction of travel for a trip. Use this field to distinguish between bi-directional trips with the same route_id. This field is not used in routing; it provides a way to separate trips by direction when publishing time tables. You can specify names for each direction with the trip_headsign field. ...  For example, you could use the trip_headsign and direction_id fields together to assign a name to travel in each direction for a set of trips. A trips.txt file could contain these rows for use in time tables ...
      t.string :block_identifier # block_id Optional The block_id field identifies the block to which the trip belongs. A block consists of two or more sequential trips made using the same vehicle, where a passenger can transfer from one trip to the next just by staying in the vehicle. The block_id must be referenced by two or more trips in trips.txt.
      t.string :shape_identifier # shape_id Optional The shape_id field contains an ID that defines a shape for the trip. This value is referenced from the shapes.txt file. The shapes.txt file allows you to define how a line should be drawn on the map to represent a trip.
      t.integer :wheelchair_accessible # wheelchair_accessible Optional 0 (or empty) - indicates that there is no accessibility information for the trip ... 1 - indicates that the vehicle being used on this particular trip can accommodate at least one rider in a wheelchair ... 2 - indicates that no riders in wheelchairs can be accommodated on this trip
      t.integer :bikes_allowed # bikes_allowed Optional 0 (or empty) - indicates that there is no bike information for the trip ... 1 - indicates that the vehicle being used on this particular trip can accommodate at least one bicycle ... 2 - indicates that no bicycles are allowed on this trip

      t.timestamps null: false
    end

    add_index :trip_versions, :version_id
    add_index :trip_versions, :route_identifier
    add_index :trip_versions, :service_identifier
    add_index :trip_versions, :identifier
    add_index :trip_versions, :block_identifier
    add_index :trip_versions, :shape_identifier
  end
end
