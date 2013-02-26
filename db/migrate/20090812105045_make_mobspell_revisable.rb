class MakeMobspellRevisable < ActiveRecord::Migration
  def self.up
    add_column :mob_spells, :revisable_original_id, :integer
    add_column :mob_spells, :revisable_branched_from_id, :integer
    add_column :mob_spells, :revisable_number, :integer
    add_column :mob_spells, :revisable_name, :string
    add_column :mob_spells, :revisable_type, :string
    add_column :mob_spells, :revisable_current_at, :datetime
    add_column :mob_spells, :revisable_revised_at, :datetime
    add_column :mob_spells, :revisable_deleted_at, :datetime
    add_column :mob_spells, :revisable_is_current, :boolean
    #make existing mobitems current
    ActiveRecord::Base.connection.execute('update mob_spells set revisable_number=1, revisable_is_current=1')
  end

  def self.down
    remove_column :mob_spells, :revisable_original_id
    remove_column :mob_spells, :revisable_branched_from_id
    remove_column :mob_spells, :revisable_number
    remove_column :mob_spells, :revisable_name
    remove_column :mob_spells, :revisable_type
    remove_column :mob_spells, :revisable_current_at
    remove_column :mob_spells, :revisable_revised_at
    remove_column :mob_spells, :revisable_deleted_at
    remove_column :mob_spells, :revisable_is_current
  end
end
