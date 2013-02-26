class SpellOwnership < ActiveRecord::Migration
  def self.up
    add_column :spells, :added_by, :integer
    add_column :spells, :updated_by, :integer
  end

  def self.down
    remove_column :spells, :added_by
    remove_column :spells, :updated_by
  end
end
