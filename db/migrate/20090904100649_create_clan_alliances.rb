class CreateClanAlliances < ActiveRecord::Migration
  def self.up
    create_table :alliances do |t|
      t.string :name, :limit => 100
      t.integer :ended_by
      t.text :conditions, :treaty
      t.string :end_reason, :limit => 250
      t.datetime :ended_at
      t.timestamps
    end
  end

  def self.down
    drop_table :alliances
  end
end
