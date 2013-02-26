class CreateClanMembers < ActiveRecord::Migration
  def self.up
    create_table :clan_members do |t|
      t.integer :clan_id, :user_id, :approved_by, :rank
      t.datetime :approved_at
      t.string :reject_reason, :limit => 200
      t.string :application, :limit => 200
      t.timestamps
    end
    add_index :clan_members, :clan_id
    add_index :clan_members, :user_id
  end

  def self.down
    drop_table :clan_members
  end
end
