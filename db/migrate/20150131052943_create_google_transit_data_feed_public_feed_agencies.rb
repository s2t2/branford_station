class CreateGoogleTransitDataFeedPublicFeedAgencies < ActiveRecord::Migration
  def change
    create_table :google_transit_data_feed_public_feed_agencies do |t|
      t.string :url #, :null => false
      t.string :name
      t.string :area
      t.timestamps null: false
    end
  end
end
