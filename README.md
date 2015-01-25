# BranfordStation

An [open transit data](https://developers.google.com/transit/gtfs/) client.

## Usage

Set-up the database.

``` sh
bundle exec rake db:create
bundle exec rake db:migrate
```

Extract and load all agencies known to the [GTFS Data Exchange](http://www.gtfs-data-exchange.com/) using one of the following methods.

``` rb
DataExchangeAgency.extract_and_load!
```

``` sh
bundle exec rake station_attendant:extract_and_load_data_exchange_agencies
```

## Contributing

0. Create a new issue discussing desired changes (optional).
1. Fork the repository.
2. Make changes.
3. Test changes and write tests, if possible, else describe desired testing logic in an issue or pull request comment. Run tests with `bundle exec rspec spec/`.
4. Push changes.
5. Create a pull request, and discuss changes as applicable.
