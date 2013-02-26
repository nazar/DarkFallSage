class DropSpellTypes < ActiveRecord::Migration
  def self.up
    drop_table :spell_types
    remove_column :spells, :spell_type_id
    remove_column :spells, :spell_type_level
  end

  def self.down
    CreateSpellTypes.up
    #
    add_column :spells, :spell_type_id, :integer
    add_column :spells, :spell_type_level, :integer
  end
end
