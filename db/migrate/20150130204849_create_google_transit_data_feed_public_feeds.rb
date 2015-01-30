class CreateGoogleTransitDataFeedPublicFeeds < ActiveRecord::Migration
  def change
    create_table :google_transit_data_feed_public_feeds do |t|

      t.timestamps null: false
    end
  end
end
