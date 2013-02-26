class CreateMobSpells < ActiveRecord::Migration
  def self.up
    create_table :mob_spells do |t|
      t.integer :mob_id, :spell_id, :mob_spell_type
      t.float :quantity
      t.timestamps
    end
    add_index :mob_spells, :mob_id
    add_index :mob_spells, :spell_id
  end

  def self.down
    drop_table :mob_spells
  end
end
