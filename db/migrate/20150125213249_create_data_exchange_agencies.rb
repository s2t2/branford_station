class CreateDataExchangeAgencies < ActiveRecord::Migration
  def change
    create_table :data_exchange_agencies do |t|
      t.string :dataexchange_id, :null => false
      t.string :name
      t.string :url
      t.string :dataexchange_url
      t.string :feed_baseurl
      t.string :license_url

      t.string :country
      t.string :state
      t.string :area

      t.boolean :is_official
      t.datetime :date_added
      t.datetime :date_last_updated

      t.timestamps null: false
    end

    add_index :data_exchange_agencies, :dataexchange_id, :unique => true
  end
end
