class CreateFeedVersions < ActiveRecord::Migration
  def change
    create_table :feed_versions do |t|
      t.integer :feed_id, :null => false
      t.datetime :last_modified_at, :null => false
      t.text :etag

      t.integer :response_code
      t.string :response_message
      t.text :accept_ranges
      #t.text :access_control_allow_origin
      t.text :cache_control
      t.text :connection
      t.text :content_type
      t.text :content_disposition
      t.text :content_language
      t.text :content_length
      t.datetime :expires
      #t.text :location
      t.text :server
      t.text :transfer_encoding
      t.text :vary
      #t.text :x_aspnet_version
      #t.text :x_frame_options
      t.text :x_powered_by
      #t.text :x_ua_compatible
      t.text :set_cookie

      t.datetime :last_checked_at
      t.timestamps null: false
    end

    add_index :feed_versions, :feed_id
    add_index :feed_versions, :last_modified_at
    #add_index :feed_versions, :last_checked_at
  end
end
