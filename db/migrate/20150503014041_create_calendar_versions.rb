class CreateCalendarVersions < ActiveRecord::Migration
  def change
    create_table :calendar_versions do |t|
      t.integer :version_id, :null => false

      # https://developers.google.com/transit/gtfs/reference#calendar_fields
      t.string :service_identifier, :null => false # service_id Required The service_id contains an ID that uniquely identifies a set of dates when service is available for one or more routes. Each service_id value can appear at most once in a calendar.txt file. This value is dataset unique. It is referenced by the trips.txt file.
      t.boolean :monday, :null => false # monday Required The monday field contains a binary value that indicates whether the service is valid for all Mondays.
      t.boolean :tuesday, :null => false # tuesday Required The tuesday field contains a binary value that indicates whether the service is valid for all Tuesdays.
      t.boolean :wednesday, :null => false # wednesday Required The wednesday field contains a binary value that indicates whether the service is valid for all Wednesdays.
      t.boolean :thursday, :null => false # thursday Required The thursday field contains a binary value that indicates whether the service is valid for all Thursdays.
      t.boolean :friday, :null => false # friday Required The friday field contains a binary value that indicates whether the service is valid for all Fridays.
      t.boolean :saturday, :null => false # saturday Required The saturday field contains a binary value that indicates whether the service is valid for all Saturdays.
      t.boolean :sunday, :null => false # sunday Required The sunday field contains a binary value that indicates whether the service is valid for all Sundays.
      t.string :start_date, :null => false # start_date Required The start_date field contains the start date for the service. The start_date field's value should be in YYYYMMDD format.
      t.string :end_date, :null => false # end_date  Required The end_date field contains the end date for the service. This date is included in the service interval. The end_date field's value should be in YYYYMMDD format.

      t.timestamps null: false
    end

    add_index :calendar_versions, :version_id
    add_index :calendar_versions, :service_identifier
    #add_index :calendar_versions, [:version_id, :service_identifier], :name => "composite_key", :unique => true
  end
end
