class CreateModerators < ActiveRecord::Migration
  def self.up
    create_table :moderators do |t|
      t.integer :user_id
      t.boolean :can_forums, :can_db
      t.timestamps
    end
    add_index :moderators, :user_id
  end

  def self.down
    drop_table :moderators
  end
end
