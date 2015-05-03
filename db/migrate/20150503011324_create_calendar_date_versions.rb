class CreateCalendarDateVersions < ActiveRecord::Migration
  def change
    create_table :calendar_date_versions do |t|
      t.integer :version_id, :null => false

      #https://developers.google.com/transit/gtfs/reference#calendar_dates_fields
      t.string :service_identifier, :null => false # service_id Required The service_id contains an ID that uniquely identifies a set of dates when a service exception is available for one or more routes. Each (service_id, date) pair can only appear once in calendar_dates.txt. If the a service_id value appears in both the calendar.txt and calendar_dates.txt files, the information in calendar_dates.txt modifies the service information specified in calendar.txt. This field is referenced by the trips.txt file.
      t.string :date, :null => false # date Required The date field specifies a particular date when service availability is different than the norm. You can use the exception_type field to indicate whether service is available on the specified date. The date field's value should be in YYYYMMDD format.
      t.integer :exception_type, :null => false # exception_type Required The exception_type indicates whether service is available on the date specified in the date field. A value of 1 indicates that service has been added for the specified date. A value of 2 indicates that service has been removed for the specified date. For example, suppose a route has one set of trips available on holidays and another set of trips available on all other days. You could have one service_id that corresponds to the regular service schedule and another service_id that corresponds to the holiday schedule. For a particular holiday, you would use the calendar_dates.txt file to add the holiday to the holiday service_id and to remove the holiday from the regular service_id schedule.

      t.timestamps null: false
    end

    add_index :calendar_date_versions, :version_id
    add_index :calendar_date_versions, :service_identifier
    #add_index :calendar_date_versions, :date
    #add_index :calendar_date_versions, [:service_identifier, :date], :name => "composite_key", :unique => true
    #add_index :calendar_date_versions, :exception_type
  end
end
