class MakePoisRevisable < ActiveRecord::Migration
  def self.up
    add_column :pois, :revisable_original_id, :integer
    add_column :pois, :revisable_branched_from_id, :integer
    add_column :pois, :revisable_number, :integer
    add_column :pois, :revisable_name, :string
    add_column :pois, :revisable_type, :string
    add_column :pois, :revisable_current_at, :datetime
    add_column :pois, :revisable_revised_at, :datetime
    add_column :pois, :revisable_deleted_at, :datetime
    add_column :pois, :revisable_is_current, :boolean
    #make existing pois current
    ActiveRecord::Base.connection.execute('update pois set revisable_number=1, revisable_is_current=1')
  end

  def self.down
    remove_column :pois, :revisable_original_id
    remove_column :pois, :revisable_branched_from_id
    remove_column :pois, :revisable_number
    remove_column :pois, :revisable_name
    remove_column :pois, :revisable_type
    remove_column :pois, :revisable_current_at
    remove_column :pois, :revisable_revised_at
    remove_column :pois, :revisable_deleted_at
    remove_column :pois, :revisable_is_current
  end
end
