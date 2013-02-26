class CreateBlocks < ActiveRecord::Migration
  def self.up
    create_table :blocks do |t|
      t.integer :block_type, :default => 0 
      t.integer :dynamic_block, :position
      t.integer :placement, :default => 1
      t.integer :placement_option, :default => 0
      t.string :title
      t.text :content
      t.integer :created_by, :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :blocks
  end
end
