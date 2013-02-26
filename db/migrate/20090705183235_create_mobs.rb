class CreateMobs < ActiveRecord::Migration
  def self.up
    #main mobs table
    create_table :mobs do |t|
      t.integer :mob_type, :difficulty, :hp
      t.string :name, :limit => 100
      t.text :description
      t.integer :created_by, :updated_by
      t.integer :images_count, :markers_count, :topics_count, :posts_count, :items_count, :spells_count, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :mobs
  end
end
