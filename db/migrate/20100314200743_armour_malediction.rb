class ArmourMalediction < ActiveRecord::Migration

  def self.up
    add_column :items, :protect_malediction, :float
  end

  def self.down
    remove_column :items, :protect_malediction
  end

end
