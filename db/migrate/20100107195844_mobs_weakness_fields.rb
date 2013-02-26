class MobsWeaknessFields < ActiveRecord::Migration

  def self.up
    add_column :mobs, 'melee_weakness', :string, {:limit => 150}
    add_column :mobs, 'spell_weakness', :string, {:limit => 150}
  end

  def self.down
    remove_column :mobs, 'melee_weakness'
    remove_column :mobs, 'spell_weakness'
    remove_column :mobs, 'caster'
  end
end
