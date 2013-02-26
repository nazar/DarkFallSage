class AddGoldItemCache < ActiveRecord::Migration

  def self.up
    add_column :skills, :gold, :float
    add_column :spells, :gold, :float
  end

  def self.down
    remove_column :skills, :gold
    remove_column :spells, :gold
  end
end
