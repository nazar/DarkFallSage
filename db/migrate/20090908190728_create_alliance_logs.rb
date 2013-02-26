class CreateAllianceLogs < ActiveRecord::Migration
  def self.up
    create_table :alliance_logs do |t|
      t.integer :alliance_id, :clan_id
      t.string :log, :limit => 200
      t.timestamps
    end
  end

  def self.down
    drop_table :alliance_logs
  end
end
