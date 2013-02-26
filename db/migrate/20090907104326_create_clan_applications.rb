class CreateClanApplications < ActiveRecord::Migration
  def self.up
    create_table :clan_applications do |t|
      t.integer :user_id, :clan_id, :actioned_by
      t.integer :status, :default => 0
      t.datetime :actioned_at
      t.string :actioned_reason, :limit => 200
      t.text :application
      t.timestamps
    end
    add_index :clan_applications, :user_id,     {:name => 'clan_applications_user'}
    add_index :clan_applications, :clan_id,     {:name => 'clan_applications_clan'}
    add_index :clan_applications, :actioned_by, {:name => 'clan_applications_actioner'}
  end

  def self.down
    drop_table :clan_applications
  end
end
