# BranfordStation

An [open transit data](https://developers.google.com/transit/gtfs/) client.

## Usage

### Specified Feed Source(s)

Extract feed files from specified sources.

```` rb
FeedConsumer.perform(:source_urls => ["http://www.shorelineeast.com/google_transit.zip", "http://web.mta.info/developers/data/mnr/google_transit.zip"])
````

### All Known Feed Source(s)

Set-up the database.

``` sh
bundle exec rake db:create
bundle exec rake db:migrate
```

Extract and load all agencies from the [GTFS Data Exchange](http://www.gtfs-data-exchange.com/) API.

``` sh
bundle exec rake station_attendant:find_data_exchange_feeds
```

Extract and load all agencies and feeds from the [Google Transit Data Feed](https://code.google.com/p/googletransitdatafeed/wiki/PublicFeeds) wiki.

``` sh
bundle exec rake station_attendant:find_google_transit_data_feeds
```

Extract feed files from all known sources.

``` sh
bundle exec rake station_attendant:consume_feeds
```

## Contributing

0. Create a [new issue](https://github.com/s2t2/branford_station/issues/new), discussing desired changes (optional).
1. [Fork](https://github.com/s2t2/branford_station/fork) the repository.
2. Make changes.
3. Test changes and write tests, if possible, else describe desired testing logic in an issue or pull request comment. Run tests with `bundle exec rspec spec/`.
4. Push changes.
5. Create a [new pull request](https://github.com/s2t2/branford_station/compare/), discussing changes as applicable.
