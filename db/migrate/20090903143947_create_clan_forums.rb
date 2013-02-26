class CreateClanForums < ActiveRecord::Migration
  def self.up
    create_table :clan_forums do |t|
      t.integer :clan_id, :access_type
      t.string :name, :limit => 100
      t.integer :position
      t.timestamps
    end
  end

  def self.down
    drop_table :clan_forums
  end
end
