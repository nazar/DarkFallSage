class CreateMobWeaknesses < ActiveRecord::Migration

  def self.up
    create_table :mob_weaknesses do |t|
      t.integer :mob_id, :weakness_type, :weakness_id
      t.timestamps
    end
    add_index :mob_weaknesses, :mob_id
  end

  def self.down
    drop_table :mob_weaknesses
  end
  
end
