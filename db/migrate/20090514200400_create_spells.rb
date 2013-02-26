class CreateSpells < ActiveRecord::Migration
  def self.up
    create_table :spells do |t|
      t.integer :spell_type_id, :spell_type_level
      t.string :name, :limit=> 20
      t.text :description
      t.integer :spell_type, :spell_target
      t.float :mana
      t.timestamps
    end
    add_index :spells, :spell_type_id, {:name => 'spells_type'}
  end

  def self.down
    drop_table :spells
  end
end
