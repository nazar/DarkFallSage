class CreatePois < ActiveRecord::Migration
  def self.up
    create_table :pois do |t|
      t.string :name, :limit => 100
      t.text :description
      t.integer :added_by, :updated_by, :poi_type
      t.integer :markers_count, :posts_count, :topics_count, :images_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :pois
  end
end
