class SpellPrereqCounter < ActiveRecord::Migration
  def self.up
    add_column :spells, :required_count, :integer, {:default => 0}
    add_column :spells, :level, :integer
  end

  def self.down
    remove_column :spells, :required_count
    remove_column :spells, :level
  end
end
