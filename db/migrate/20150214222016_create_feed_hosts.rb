class CreateFeedHosts < ActiveRecord::Migration
  def change
    create_table :feed_hosts do |t|
      t.string :name, :null => false
      t.timestamps null: false
    end

    add_index :feed_hosts, :name, :unique => true
  end
end
