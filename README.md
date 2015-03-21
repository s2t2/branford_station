# Branford Station

A tool for consuming and presenting open transit data published according to the [General Transit Feed Specification (GTFS)](https://developers.google.com/transit/gtfs/).

This application
 finds all known sources of GTFS data,
 consumes GTFS data from source,
 and presents GTFS data to the public through a web interface.

##  Usage

### API Endpoints

 + **/agencies** (lists all participating transit agencies)
 + **/agencies/`:agency_abbrev`** (lists all train stations serviced by a given agency)
 + **/agencies/`:agency_abbrev`/stations/`:station_abbrev`** (lists upcoming departures from a given station)

These endpoints return HTML by default. To request a JSON response instead, suffix `.json` to the endpoint url.

### Ad-hoc Feed Consumption

Specify one or more feed source urls for ad-hoc consumption.
```` rb
FeedConsumer.perform(:source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"])
````

By default this will download feed files to your local fylesystem.
 To load file contents into the database, pass `:load => true` as consumption request options.
 ```` rb
FeedConsumer.perform(:source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"], :load => true)
````

### Systematic Feed Discovery and Consumption

Find all known sources of GTFS Data from community sites.

Find feeds from the [GTFS Data Exchange](http://www.gtfs-data-exchange.com/).
```` sh
bundle exec rake station_attendant:find_data_exchange_feeds
````

Find feeds from the [Google Transit Data Feed - Public Feeds Wiki](https://code.google.com/p/googletransitdatafeed/wiki/PublicFeeds).
```` sh
bundle exec rake station_attendant:find_google_transit_data_feeds
````

Consume GTFS data from all known feed sources.
``` sh
bundle exec rake station_attendant:consume_feeds
```

## Contributing

Issues and Pull Requests are welcome.

### Development Environment

Install dependencies for a Ruby on Rails application.

### Production Environment

Optionally use [this script](https://github.com/s2t2/trailmix-solo) to deploy the application to a remote, hosted server.
