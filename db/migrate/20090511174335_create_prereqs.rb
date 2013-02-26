class CreatePrereqs < ActiveRecord::Migration
  def self.up
    create_table :prereqs do |t|
      t.string  :prereqable_type, :limit => 20
      t.integer :prereqable_id, :prereq_type, :prereq_id
      t.float :qty
      t.timestamps
    end
    add_index :prereqs, :prereqable_id, {:name => 'prereqable_id'}
    add_index :prereqs, :prereq_id
  end

  def self.down
    drop_table :prereqs
  end
end
