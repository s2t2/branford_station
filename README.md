# Branford Station

An open transit data client using the [General Transit Feed Specification (GTFS)](https://developers.google.com/transit/gtfs/).

This application
 finds known sources of GTFS data,
 consumes GTFS data from known sources,
 and communicates the resulting transit information to the general public through a web interface.

## General Usage

View live at [next-train.info](http://next-train.info).

Find participating transit agencies.
 > http://next-train.info/agencies

Find all train stations serviced by a given agency, in this case *Shore Line East (SLE)*.
 > http://next-train.info/agencies/SLE/stations

Find the upcoming schedule of departures for a given station, in this case *Branford (BNF)*.
 > http://next-train.info/agencies/SLE/stations/BNF

## Developer Usage

Find sources of GTFS Data from community sites including
 the [GTFS Data Exchange](http://www.gtfs-data-exchange.com/)
 and the [Google Transit Data Feed - Public Feeds Wiki](https://code.google.com/p/googletransitdatafeed/wiki/PublicFeeds).

```` sh
bundle exec rake station_attendant:find_data_exchange_feeds
bundle exec rake station_attendant:find_google_transit_data_feeds
````

Consume GTFS data from all known sources, or specify one or more feed source locations for ad-hoc consumtion.
``` sh
bundle exec rake station_attendant:consume_feeds
```

```` rb
FeedConsumer.perform(:source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"])
````

## Contributing

Issues and Pull Requests are welcome.

### Development Environment

Install dependencies for a Ruby on Rails application.

### Production Environment

Optionally use [this script](https://github.com/s2t2/trailmix-solo) to deploy the application to a remote, hosted server.
