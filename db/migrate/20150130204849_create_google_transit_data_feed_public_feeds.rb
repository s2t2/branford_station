class CreateGoogleTransitDataFeedPublicFeeds < ActiveRecord::Migration
  def change
    create_table :google_transit_data_feed_public_feeds do |t|
      t.integer :agency_id #, :null => false
      t.string :url #, :null => false
      t.text :notes
      t.timestamps null: false
    end

    add_index :google_transit_data_feed_public_feeds, :agency_id #, :unique => true
  end
end
