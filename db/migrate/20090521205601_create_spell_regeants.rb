class CreateSpellRegeants < ActiveRecord::Migration
  
  def self.up
    create_table :spell_reagents do |t|
      t.integer :item_id, :spell_id, :added_by
      t.float :qty
      t.timestamps
    end
    add_index :spell_reagents, :item_id, {:name => :spell_reagents_item}
    add_index :spell_reagents, :spell_id, {:name => :spell_reagents_spell}
  end

  def self.down
    drop_table :spell_reagents
  end
end
