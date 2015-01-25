# BranfordStation

An [open transit data](https://developers.google.com/transit/gtfs/) client.

## Usage

Set-up the database.

``` sh
bundle exec rake db:create
bundle exec rake db:migrate
```

Extract and load all agencies known to the [GTFS Data Exchange](http://www.gtfs-data-exchange.com/).

``` sh
bundle exec rake station_attendant:extract_and_load_data_exchange_agencies
```

## Contributing

0. Create a [new issue](https://github.com/s2t2/branford_station/issues/new), discussing desired changes (optional).
1. [Fork](https://github.com/s2t2/branford_station/fork) the repository.
2. Make changes.
3. Test changes and write tests, if possible, else describe desired testing logic in an issue or pull request comment. Run tests with `bundle exec rspec spec/`.
4. Push changes.
5. Create a [new pull request](https://github.com/s2t2/branford_station/compare/), discussing changes as applicable.
