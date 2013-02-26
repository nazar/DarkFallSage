class MakeMobRevisable < ActiveRecord::Migration
  
  def self.up
    add_column :mobs, :revisable_original_id, :integer
    add_column :mobs, :revisable_branched_from_id, :integer
    add_column :mobs, :revisable_number, :integer
    add_column :mobs, :revisable_name, :string
    add_column :mobs, :revisable_type, :string
    add_column :mobs, :revisable_current_at, :datetime
    add_column :mobs, :revisable_revised_at, :datetime
    add_column :mobs, :revisable_deleted_at, :datetime
    add_column :mobs, :revisable_is_current, :boolean
    #make existing mobs current
    ActiveRecord::Base.connection.execute('update mobs set revisable_number=1, revisable_is_current=1')
  end

  def self.down
    remove_column :mobs, :revisable_original_id
    remove_column :mobs, :revisable_branched_from_id
    remove_column :mobs, :revisable_number
    remove_column :mobs, :revisable_name
    remove_column :mobs, :revisable_type
    remove_column :mobs, :revisable_current_at
    remove_column :mobs, :revisable_revised_at
    remove_column :mobs, :revisable_deleted_at
    remove_column :mobs, :revisable_is_current
  end
end
