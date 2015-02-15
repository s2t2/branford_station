class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.integer :host_id, :null => false
      t.string :source_url, :null => false
      t.string :name
      t.timestamps null: false
    end

    add_index :feeds, :host_id
    add_index :feeds, :source_url, :unique => true
  end
end
