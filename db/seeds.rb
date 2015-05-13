# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

FeedConsumer.perform(:load => true, :source_urls => [
  "http://www.shorelineeast.com/google_transit.zip",
  "http://web.mta.info/developers/data/mnr/google_transit.zip",
  "http://www.bart.gov/dev/schedules/google_transit.zip",
  "http://www.caltrain.com/Assets/GTFS/caltrain/GTFS-Caltrain-Devs.zip",
  "http://www.transitchicago.com/downloads/sch_data/google_transit.zip"
])
