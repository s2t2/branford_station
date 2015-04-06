# Branford Station

This application
 finds sources of [General Transit Feed Specification (GTFS)](https://developers.google.com/transit/gtfs/) open transit data from community-maintained sites like
  the [GTFS Data Exchange](http://www.gtfs-data-exchange.com/) and 
  the [Google Transit Data Feed Wiki](https://code.google.com/p/googletransitdatafeed/wiki/PublicFeeds),
 periodically checks feed sources to confirm current data or download new data,
 and makes the data available for public consumption through an api and front-end interface.

##  Usage

### Find data sources

```` sh
bundle exec rake station_attendant:find_data_exchange_feeds
````

```` sh
bundle exec rake station_attendant:find_google_transit_data_feeds
````

### Consume data from source

``` sh
bundle exec rake station_attendant:find_and_consume_and_load
```

#### Other sources

You may also specify one or more feed source urls for ad-hoc consumption.

Download feed files onto filesystem.

```` rb
FeedConsumer.perform(:source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"])
````

Or load files into database.

 ```` rb
FeedConsumer.perform(:source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"], :load => true)
````

### API Endpoints

Once persisted, make HTTP requests or view GTFS data in a browser using the endpoint urls listed below.

 + **/agencies** (lists all participating transit agencies)
 + **/agencies/`:agency_abbrev`** (lists all train stations serviced by a given agency)
 + **/agencies/`:agency_abbrev`/stations/`:station_abbrev`** (lists upcoming departures from a given station)

These endpoints return HTML by default. To request a JSON response instead, suffix `.json` to the endpoint url.

## Contributing

To request a new feature, [create an issue](https://github.com/s2t2/branford_station/issues/new).

To deliver a new feature, [fork the repo](https://github.com/s2t2/branford_station/issues#fork-destination-box), make your changes, add tests if possible, and submit a pull request.

### Development Environment Setup

Install dependencies for a Ruby on Rails application.

### Production Environment Considerations

Thanks to *HOSTING ORGANIZATION HERE* for hosting this application in production.
