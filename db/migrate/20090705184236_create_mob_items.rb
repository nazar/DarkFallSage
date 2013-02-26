class CreateMobItems < ActiveRecord::Migration
  def self.up
    create_table :mob_items do |t|
      t.integer :mob_id, :item_id, :mob_item_type
      t.float :quantity
      t.timestamps
    end
    add_index :mob_items, :mob_id
    add_index :mob_items, :item_id
  end

  def self.down
    drop_table :mob_items
  end
end
