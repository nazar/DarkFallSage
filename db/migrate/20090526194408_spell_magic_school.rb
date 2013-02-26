class SpellMagicSchool < ActiveRecord::Migration

  def self.up
    add_column :spells, :school_id, :integer
    add_index :spells, :school_id
  end

  def self.down
    remove_column :spells, :school_id
  end
end
