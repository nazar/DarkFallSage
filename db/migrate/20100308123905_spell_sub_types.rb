class SpellSubTypes < ActiveRecord::Migration

  def self.up
    add_column :spells, :sub_type, :integer
    #clear mob spell weakness cache...
    Mob.update_all('spell_weakness = null')
    #clear mob_weaknesses table
    MobWeakness.delete_all('weakness_type = 0')
  end

  def self.down
    remove_column :spells, :sub_type
  end

end
