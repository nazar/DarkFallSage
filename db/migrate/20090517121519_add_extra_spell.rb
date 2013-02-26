class AddExtraSpell < ActiveRecord::Migration
  def self.up
    add_column :spells, :cool_down, :float
    add_column :spells, :time_to_cast, :float
  end

  def self.down
    remove_column :spells, :cool_down
    remove_column :spells, :time_to_cast
  end
end
