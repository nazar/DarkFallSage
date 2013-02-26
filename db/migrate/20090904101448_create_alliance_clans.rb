class CreateAllianceClans < ActiveRecord::Migration
  def self.up
    create_table :alliance_clans do |t|
      t.integer :alliance_id, :clan_id
      t.timestamps
    end
    add_index :alliance_clans, :alliance_id, {:name => 'alliance_clans_alliance'}
    add_index :alliance_clans, :clan_id, {:name => 'alliance_clans_clan'}
  end

  def self.down
    drop_table :alliance_clans
  end
end
