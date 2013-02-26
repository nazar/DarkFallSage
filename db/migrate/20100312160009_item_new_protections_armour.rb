class ItemNewProtectionsArmour < ActiveRecord::Migration

  def self.up
    add_column :items, :protect_mental, :float
    add_column :items, :protect_arcane, :float
  end

  def self.down
    remove_column :items, :protect_mental
    remove_column :items, :protect_arcane
  end

end
