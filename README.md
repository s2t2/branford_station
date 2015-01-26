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

Extract and load all public feeds listed on the [Google Transit Data Feed](https://code.google.com/p/googletransitdatafeed/wiki/PublicFeeds) wiki.
``` sh
bundle exec rake station_attendant:extract_and_load_google_transit_feed_agencies
```

`` rb
  require 'open-uri'
  require 'nokogiri'
  # Persists all public feeds listed on the google transit data feeds public feeds wiki page.
  def self.extract_and_load!
    document = Nokogiri::HTML(open("https://code.google.com/p/googletransitdatafeed/wiki/PublicFeeds"))
    #raise MissingDocumentError unless document

    tables = document.css("table")

    wiki_table = tables.find{|t| t.attributes["class"].try(:value) == "wikitable"}
    #raise MissingWikiTableError unless wiki_table

    wiki_table_rows = wiki_table.css("tr")
    wiki_table_rows.each do |row|
      next if row.content.include?("Agency") && row.content.include?("Area") && row.content.include?("Feed") && row.content.include?("Location") && row.content.include?("Notes") # header_row
      pp row.content
    end
  end
``

## Contributing

0. Create a [new issue](https://github.com/s2t2/branford_station/issues/new), discussing desired changes (optional).
1. [Fork](https://github.com/s2t2/branford_station/fork) the repository.
2. Make changes.
3. Test changes and write tests, if possible, else describe desired testing logic in an issue or pull request comment. Run tests with `bundle exec rspec spec/`.
4. Push changes.
5. Create a [new pull request](https://github.com/s2t2/branford_station/compare/), discussing changes as applicable.
