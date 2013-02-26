class CreateReputations < ActiveRecord::Migration
  def self.up
    create_table :reputations do |t|
      t.integer :user_id
      t.integer :reputation, :total, :default => 0
      t.integer :updated_by
      t.string :reason, :limit => 200
      t.timestamps
    end
    add_index :reputations, :user_id
  end

  def self.down
    drop_table :reputations
  end
end
