class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.boolean :craftable, :default => false
      t.integer :item_type, :item_sub_type, :added_by, :updated_by
      t.integer :weapon_skill, :weapon_rank
      t.float   :protect_acid, :protect_arrow, :protect_bludge, :protect_cold, :protect_fire, :protect_light, :protect_pierce, :protect_slash
      t.float   :weight, :weapon_attack_mult, :weapon_basic_damage, :durability_max, :durability, :quality, :npc_cost, :encumbrance
      t.string  :name, :limit => 200
      t.text    :description
      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
