class AddAttackSpeedToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :attack_speed, :float
  end

  def self.down
    remove_column :items, :attack_speed
  end
end
